     H dftactgrp(*no) actgrp(*new) bnddir('ANZAPPR') debug

     fAnzapp90  uf a e           k disk    usropn
     fAnzappf   cf   e             workstn sfile(@tree: rrn) usropn
     f                                     sfile(@chcsf: rrna) infds(forevent)
     f                                     sfile(@sbx: rrnb)

     d/include anzapps,xcommonds
     d/include anzapps,xsrvproto

     D ANZAPPR         pr
     d  entryParm                    10    options(*nopass)
     D ANZAPPR         pi
     d  entryParm                    10    options(*nopass)

     d $APPMAX$        c                   36

     D Cee4rage        pr
     d  proc                           *   procptr const
     d  fc                           12    options(*omit)
     D qCmd            pr                  extpgm('QCMD')

     D SetupHbch       pr
     D SetupXref       pr
     d  apps                         10    value
     D GetRoot         pr              *
     d  apps                         10    value
     d  fromObj                      10    value
     d  objLib                       10    value
     d  objUsage                     10    value
     D backward        s               n   inz Export

     d ChgLibl         pr             1  0
     d  apps                         10    value options(*nopass)
     d MappingSrc      pr
     d  mapLibTo                     10
     d Xref            pr
     d  pLst                           *   value
     d  pLst1                          *   value
     d  what                         10    value
     D PrtLayout       pr                  extpgm('PRTSRCR')
     d  qualPgm                      20
     d  dummy                         1
     D DspHelp         pr

     D InterMain       pr
     d SetAppSys       pr
     d  apps                         10    value
     d  desc                         50    value options(*nopass)
     d SetExempt       pr
     d SetMapSrcLib    pr
     d ChgFileUsage    pr
     d SetAppLst       pr
     d SelModule       pr            10
     d  xpos                          3  0 value
     d  ypos                          3  0 value
     d  objtype                      10    value
     d  qualObj                      20    value
     d  lib                          10
     d  srcpf                        10    options(*omit)
     d GetObjType      pr            10
     d  objlib                       10
     d  obj                          10    value
     d  xpos                          3  0 value
     d  ypos                          3  0 value
     d GetInp          pr
     d  xpos                          3  0 value
     d  ypos                          3  0 value
     d  prompt                        7    value
     d GetChc          pr             5  0
     d  title                        14    value
     d  xpos                          3  0 value
     d  ypos                          3  0 value
     d  fromLst                        *   value options(*string)
     d  fromLst1                       *   value options(*string)
     d  defultChc                    10    value
     d  xRefWhat                     10    value options(*nopass)
     D ToLevel         pr             1  0
     d  plastlvl                       *   value
     d  totlvl                        2  0 value
     D GetRrn          pr             5  0
     d  string                      128    value
     D WrkObj          pr
     d  toDo                         10    value options(*nopass)
     d WrkSch          pr              n
     d  phase                         3    value
     d SearchFor       pr
     d  string                             like(@sbxfor) value options(*nopass)
     d  pflib                        10    value options(*nopass)
     d  pf                           10    value options(*nopass)
     d  pfm                          10    value options(*nopass)
     d  style                         2  0 value options(*nopass)
     d  casesense                     2  0 value options(*nopass)
     D ExtActGrp       pr

     d node_ds         ds
     d  obj                          10
     d  usage                         2p 0
     d  next                           *
     d  lvllnk                         *
     d  up_ref                         *
     d objTypes        s             10    dim(4) ctdata

     d forevent        ds
     d  mouse_event          369    369
     d  csr_row              370    370
     d  csr_col              371    371

     d                 ds
     d @csrc                   2      2
     d @csr                    1      2b 0 inz
     d                 ds
     d @cscc                   2      2
     d @csc                    1      2b 0 inz

     d appLst          ds                  qualified
     d  names                        10    dim($APPMAX$)
     d  descs                        50    dim($APPMAX$)
     d arrTree         s            128    dim(9999)
     d rrn             s              5  0
     d rrna            s              5  0
     d rrnb            s              5  0
     d totRrn          s              5  0
     d duringSearch    s               n   inz

      /free
       if %parms() < 1;
          SetupHbch();
       elseif %subst(entryParm: 1: 1) = '*';
          InterMain();
       else;
          SetupXref(entryParm);
       endif;

       return;
      /end-free

     csr   *inzsr        begsr
     c                   callp     Cee4rage(%paddr(ExtActGrp): *omit)
     csr                 endsr

     P InterMain       b
     d InterMain       pi

     d level           s              2  0 inz(1)
     d chcidx          s              5  0

      /free
       open Anzapp90;
       open Anzappf;

       callp SetAppLst();

       chain(n) psds.job_user Anzapp90;
       if not %found;
          clear R90;
          f9usr = psds.job_user;
       endif;

       dou @mnbfld = 1 and @file = 90;
          write @msgl;
          write @mnubr;
          read @mnubr;
          @msg = *blank;

          select;
             when @mnbfld = 1;
                read @pulld1;

                if @file = 90; //exit
                   leave;
                endif;

                if @file = 11 and f9apps = *blank;    //renew
                   @msg = 'Open an application first.';
                   iter;
                endif;

                exsr SrPullD1;

             when @mnbfld = 2;
                read @pulld2;            // up/down

                if @link = 0;
                   iter;
                endif;

                if f9apps = *blank;
                   @msg = 'Open an application first.';
                   iter;
                endif;

                exsr SrPullD2;

             when @mnbfld = 3;
                read @pulld3;
                if @about = 1;
                   DspHelp();
                elseif @about = 2;
                   @ax = @cx3;
                   @ay = @cy3 + 6;
                   exfmt @abtwnd;
                endif;
          endsl;
       enddo;

       close Anzapp90;
       close Anzappf;
       return;

       begsr SrPullD1;
          select;
             when @file = 1 or @file = 2 and appLst.names(1) = *blank; // new -
                callp GetInp(@cx1: @cy1: 'System:');

                if @input <> *blank;
                   callp SetAppSys(@input);
                   callp SetAppLst();
                endif;

             when @file = 2;                                     // open
                chain psds.job_user Anzapp90;
                if %found(Anzapp90);
                   f9apps = appLst.names(GetChc('  App System  ': @cx1: @cy1:
                                                %addr(appLst): *null: f9apps));
                   update R90;
                else;
                   f9apps = appLst.names(GetChc('  App System  ': @cx1: @cy1:
                                                %addr(appLst): *null:
                                                appLst.names(1)));
                   write R90;
                endif;

             when @file = 11;                                    // renew
                callp SetAppSys(f9apps:
                                appLst.descs(%lookup(f9apps: appLst.names)));

             when @file = 21;                                    // set exemptio
                callp SetExempt();

             when @file = 22;
                  SetMapSrcLib();

             when @file = 31;
                callp ChgFileUsage();
          endsl;
       endsr;

       begsr SrPullD2;
          if @link = 1;
             backward = *off;
          elseif @link = 2;
             backward = *on;
          endif;
          exsr LinkUp;
       endsr;

       begsr LinkUp;
          dou *inKL or @psbtfd = 1;  //CA12
              if @root = *blank;
                 callp GetInp(@cx2: @cy2: 'From:');
                 if @input = *blank;
                    leave;
                 endif;

                 @root = @input;

                 if @root = '*VARIABLE';
                    @roott = 'P';
                 endif;

                 if f9apps = 'HUB8_BCH';
                    @roott = '*HUBBCH';
                 endif;

                 if @roott = *blank;
                    @roott = GetObjType(@rootl: @root: @wx: @wy + 10);
                    if @roott = *blank;
                       @msg = %trim(@root) + ' with type *FILE/*PGM/*SRVPGM/*D+
                              TAARA not found.';
                       leave;
                    elseif @roott = '*FILE' and backward;
                       @msg = %trim(@root) + ' is a file, not applicable to +
                              program references.';
                       leave;
                    endif;
                 endif;
                 level = 1;
              endif;

              *in91 = *on;
              write @treec;
              *in91 = *off;
              @msg = *blank;
              rrn = 0;

              clear @brchs;
              clear arrTree;

              if (@roott = '*FILE' or backward) and
                 ToLevel(GetRoot(f9apps: @root: @rootl: entryParm): level) = 0
                 or @roott <> '*FILE' and not backward and
                 ToLevel(GetRoot(f9apps: @root: @rootl: @roott): level) = 0;
                 totRrn = rrn;
                 if rrn > 0;
                    if @frlsp = *blank;
                       @csrp = 1;
                    else;
                       @csrp = GetRrn(@frlsp);
                    endif;
                 else;
                    rrn = 1;
                    clear @brchs;
                    write @tree;
                 endif;
              endif;

              callp WrkObj('*RESETSEL');

              dou *inKL or @psbtfd = 1; //CA12
                  if @csrp <= 0 or @csrp > totRrn;
                    @csrp = 1;
                  endif;
                  if totRrn > 0;
                     @frlsp = arrTree(@csrp);             //show the good one
                  endif;

                 write @msgl;

                 if duringSearch;
                    exfmt @sbxc;
                 else;
                    exfmt @treec;

                    @csrp = @csrg;
                    if totRrn > 0;
                       @frlsp = arrTree(@csrp);             //save for --> and <
                    endif;
                 endif;

                 @csrc = csr_row;
                 @cscc = csr_col;
                 @msg = *blank;

                 select;
                 when duringSearch;
                      if *inKL;     //F12
                          duringSearch = WrkSch('CNL');
                          *inKL = *off;
                      elseif *inKA;     //F1
                          duringSearch = WrkSch('CFM');
                      elseif mouse_event = x'f1';                  //mouse click
                          duringSearch = WrkSch('SEL');
                      endif;

                 when *inKL or @psbtfd = 1;   //F12
                      leave;

                 when *inKE or @psbtfd = 2;   //F5
                      level = 1;
                      clear @root;
                      clear @roott;
                      clear @frlsp;
                      leave;

                 when (*inKQ or @psbtfd = 3) and totRrn > 0;                  //
                      callp WrkObj('*FIND');

                 when (*inKT or @psbtfd = 4) and level > 1;     //F19
                      level = level - 1;
                      leave;

                 when (*inKU or @psbtfd = 9) and level < 11 and totRrn > 0;   //
                      level = level + 1;
                      leave;

                 when *inKV or @psbtfd = 5;               //F21
                      callp qCmd();

                 when *inKW or @psbtfd = 6;               //F22
                      callp WrkObj('*LAYOUT');

                 when *inKX or @psbtfd = 7;               //F23
                      callp WrkObj('*DISPLAY');

                 when *inKY or @psbtfd = 8;               //F24
                      callp WrkObj('*SOURCE');

                 when (*inKR or @psbtfd = 10) and totRrn > 0;     //F17
                      duringSearch = WrkSch('INZ');

                 when mouse_event = x'F1' and                     //mouse click
                      @csr > 3 and @csc > 1 and @csc < 130 and totRrn > 0;
                      WrkObj('*SELECT');
                 endsl;
              enddo;
          enddo;

          clear @root;
          clear @roott;
          clear @frlsp;
       endsr;
      /end-free
     P InterMain       e

     P SetAppSys       b
     D SetAppSys       pi
     d  apps                         10    value
     d  desc                         50    value options(*nopass)

      /free

       if %parms = 2 and
          xExeCmd('?STRSEU SRCFILE(ANZAPPS) SRCMBR(' +
                  %trim(apps) + ') TYPE(OBJLIBS) OPTION(2) TEXT(' +
                  %trim(desc) + ')') <> *blank or
          %parms <> 2 and
          xExeCmd('?STRSEU SRCFILE(ANZAPPS) SRCMBR(' +
                  %trim(apps) + ') TYPE(OBJLIBS) OPTION(2)') <> *blank;
          @msg = 'Edit object libraries error.';
          return;
       endif;

       GetInp(@cx1: @cy1: 'Sure?');
       if @input <> 'YES';
          return;
       endif;

       if apps = 'HUB8_BCH';
          if xExeCmd('SBMJOB CMD(CALL PGM(ANZAPPR)) +
                      JOB(ANZAPP) JOBQ(QBATCH)') <> *blank;
             @msg = 'Anzapp job submit error.';
             return;
          endif;

          @msg = 'Job submitted to set up Xreference for the application, +
                 please check job log when finished.';
          return;
       endif;

       if xExeCmd('SBMJOB CMD(CALL PGM(ANZAPPR) PARM(' +
                  x'7d' + %trim(apps) + x'7d' +
                  ')) JOB(ANZAPP) JOBQ(QBATCH)') <> *blank;
          @msg = 'Anzapp job submit error.';
          return;
       endif;

       @msg = 'Job submitted to set up Xreference for the application, +
              please check job log when finished.';

       return;
      /end-free
     P SetAppSys       e

     P SetExempt       b
     d SetExempt       pi
      /free
       if xExeCmd('UPDDTA FILE(ANZAPP10)') <> *blank;
          @msg = 'Set up exempted object fail.';
       else;
          @msg = 'Restart the command to apply the new setting.';
       endif;

       return;
      /end-free
     P SetExempt       e

     P SetMapSrcLib    b
     d SetMapSrcLib    pi
      /free
       if xExeCmd('UPDDTA FILE(ANZAPP20)') <> *blank;
          @msg = 'Set up mapping source library fail.';
       else;
          @msg = 'Restart the command to apply the new setting.';
       endif;

       return;
      /end-free
     P SetMapSrcLib    e

     P SetAppLst       b
     d SetAppLst       pi

     d al@             s              3  0
     d et@             s              3  0
     d nbrEntry        s              9b 0
     d szEntry         s              9b 0
     d lst             ds                  likeds(dsMbrl0200) based(lstPtr)
     d lstPtr          s               *

      /free
       lstPtr = xLstPfm(nbrEntry: szEntry: MBRL0200: 'ANZAPPS   *LIBL');
       if lstPtr = *null;
          return;
       endif;

       clear appLst;

       al@ = 0;
       for et@ = 1 to nbrEntry;
          if lst.type = 'OBJLIBS';
             al@ = al@ + 1;
             appLst.Names(al@) = lst.name;
             appLst.Descs(al@) = lst.text;
          endif;
          lstPtr = lstPtr + szEntry;
       endfor;

       return;
      /end-free
     P SetAppLst       e

     P ChgFileUsage    b
     d ChgFileUsage    pi

     d selLst          s             10    dim(4) static inz
     d rtnChc          s              5  0
      /free
       selLst(1) = '*CHANGE';
       selLst(2) = '*ANY';
       selLst(3) = '*ADDONLY';
       rtnChc = GetChc('  File Usage  ': @cx3: @cy3:
                       %addr(selLst): *null: entryParm);
       if rtnChc <> 0;
          entryParm = selLst(rtnChc);
       endif;
       return;
      /end-free
     P ChgFileUsage    e

     P SelModule       b
     d SelModule       pi            10
     d  xpos                          3  0 value
     d  ypos                          3  0 value
     d  objtype                      10    value
     d  qualObj                      20    value
     d  lib                          10
     d  srcpf                        10    options(*omit)

     d modLst          s             10    dim(1000)
     d libLst          s             10    dim(1000)
     d pgmInf          ds                  likeds(dsPGMI0100)
     d spgInf          ds                  likeds(dsSPGI0100)
     d lstPtr          s               *
     d savLstPtr       s               *
     d lst             ds                  likeds(dsPGML0100) based(ptr@)
     d ptr@            s               *
     d savLst          ds                  likeds(dsPGML0100) based(savPtr@)
     d savPtr@         s               *
     d nEnt            s              9b 0
     d szEnt           s              9b 0
     d ent@            s              9b 0
     d rtnMod@         s              5  0

      /free
       if objType = '*PGM';
          if xRtvPgmInf(%addr(pgmInf): %size(pgmInf): PGMI0100: qualObj) <>
             *blank;
             return *blank;
          endif;

          if pgmInf.typeOfPgm = ' ' and %addr(srcpf) = *null;  //OPM, no module
             return *blank;
          endif;

          if pgmInf.typeOfPgm = ' ';                   //OPM, pgm source
             srcpf = pgmInf.srcpf;
             lib = pgmInf.srcpfl;
             return pgmInf.srcpfm;
          endif;

          lstPtr = xLstPgmMod(nEnt: szEnt: PGML0100: qualObj);
          if lstPtr = *null;
             return *blank;
          endif;

          ptr@ = lstPtr;

          if nEnt = 1 and %addr(srcpf) = *null and
             lst.modl = 'QTEMP';
             return *blank;
          endif;

          if nEnt = 1 and %addr(srcpf) <> *null;       //only one module, return
             srcpf = lst.srcpf;
             lib = lst.srcpfl;
             return lst.srcpfm;
          endif;

          if nEnt > 1000;
             return *blank;
          endif;

          clear modLst;                                //ILE, typeofpgm=B
          clear libLst;

          for ent@ = 1 to nEnt;
              modLst(ent@) = lst.mod;
              libLst(ent@) = lst.modl;
              ptr@ = ptr@ + szEnt;
          endfor;

       elseif objType = '*SRVPGM';
          if xRtvSpgInf(%addr(spgInf): %size(spgInf): SPGI0100: qualObj) <>
             *blank;
             return *blank;
          endif;

          lstPtr = xLstSpgMod(nEnt: szEnt: SPGL0100: qualObj);
          if lstPtr = *null;
             return *blank;
          endif;

          ptr@ = lstPtr;
          clear modLst;
          clear libLst;
          ent@ = 0;

          if %addr(srcpf) <> *null;
             ent@ = ent@ + 1;
             modLst(ent@) = 'Export';
             libLst(ent@) = 'Source';
          endif;

          for ent@ = 1 to nEnt;
              modLst(ent@) = lst.mod;
              libLst(ent@) = lst.modl;
              ptr@ = ptr@ + szEnt;
          endfor;
       endif;

       exsr SetSavLst;

       rtnMod@ = GetChc(' Sel Modules  ': xpos: ypos:
                        %addr(modLst): %addr(libLst): *blank:
                        'ModExtXref');

       if rtnMod@ = 0;
          exsr RlsSavLst;
          return *blank;
       endif;

       if %addr(srcpf) = *null;
          lib = libLst(rtnMod@);
          exsr RlsSavLst;
          return modLst(rtnMod@);
       endif;

       //if objType = '*SRVPGM' and rtnMod@ = 1;
       //   srcpf = spgInf.srcpf;
       //   lib = spgInf.srcpfl;
       //   exsr RlsSavLst;
       //   return spgInf.srcpfm;
       //endif;

       ptr@ = savLstPtr;
       for ent@ = 1 to nEnt;
           if lst.mod = modLst(rtnMod@);
              srcpf = lst.srcpf;
              lib = lst.srcpfl;
              return lst.srcpfm;
           endif;
           ptr@ = ptr@ + szEnt;
       endfor;

       exsr RlsSavLst;
       return *blank;

       begsr SetSavLst;
          savLstPtr = %alloc(nEnt * szEnt);
          ptr@ = lstPtr;
          savPtr@ = savLstPtr;
          for ent@ = 1 to nEnt;
              savLst = lst;
              ptr@ = ptr@ + szEnt;
              savPtr@ = savPtr@ + szEnt;
          endfor;
       endsr;
       begsr RlsSavLst;
          dealloc(n) savLstPtr;
       endsr;
      /end-free
     P SelModule       e

     P GetObjType      b
     d GetObjType      pi            10
     d  objlib                       10
     d  obj                          10    value
     d  xpos                          3  0 value
     d  ypos                          3  0 value

     d typesGot        s             10    dim(86)
     d libsGot         s             10    dim(86)
     d rt@             s              2  0
     d ot@             s              2  0
     d dft@            s              2  0 inz
     d rtnChc          s              5  0 inz
     d objLst          ds                  likeds(dsObjl0100) based(lstPtr)
     d lstPtr          s               *
     d nbrEnt          s              9b 0
     d szEnt           s              9b 0

      /free
       clear typesGot;

       if ChgLibl(f9apps) < 0;
          return *blank;
       endif;

       lstPtr = xLstObj(nbrEnt: szEnt: OBJL0100: obj + '*LIBL');
       if ChgLibl() < 0;
          return *blank;
       endif;

       if lstPtr = *null or nbrEnt <= 0;
          callp GetInp(xpos: ypos: 'Lib:');
          if @input = *blank;
             return *blank;
          endif;
          lstPtr = xLstObj(nbrEnt: szEnt: OBJL0100: obj + @input);
          if lstPtr = *null or nbrEnt <= 0;
             return *blank;
          endif;
       endif;

       objlib = *blank;
       clear typesGot;
       clear libsGot;

       rt@ = 0;
       for nbrEnt = nbrEnt downto 1;
          ot@ = %lookup(objLst.type: objTypes);
          if ot@ > 0;
             if dft@ = 0 or ot@ < dft@;
                dft@ = ot@;
             endif;
             rt@ = rt@ + 1;
             if rt@ > 40;
                return *blank;
             endif;
             typesGot(rt@) = objLst.type;
             libsGot(rt@) = objLst.lib;
          endif;
          lstPtr = lstPtr + szEnt;
       endfor;

       if rt@ = 0;
          return *blank;
       endif;

       if rt@ = 1;
          objlib = libsGot(1);
          return typesGot(1);
       endif;

       rtnChc = GetChc('Dup ' + %trim(obj): xpos: ypos:
                       %addr(typesGot): %addr(libsGot): objTypes(dft@));

       objlib = libsGot(rtnChc);
       return typesGot(rtnChc);
      /end-free
     P GetObjType      e

     P GetInp          b
     d GetInp          pi
     d  xpos                          3  0 value
     d  ypos                          3  0 value
     d  prompt                        7    value
      /free
       if xpos + 2 + 2 > 24;
          @wx = 24 - 2 - 2;
       else;
          @wx = xpos;
       endif;

       if ypos + 6 + 18 + 4 > 132;
          @wy = 132 - 18 - 4 - 6;
       else;
          @wy = ypos + 6;
       endif;

       @prompt = prompt;
       exfmt @inpwnd;
       return;
      /end-free
     P GetInp          e

     P GetChc          b
     d GetChc          pi             5  0
     d  title                        14    value
     d  xpos                          3  0 value
     d  ypos                          3  0 value
     d  fromLst                        *   value options(*string)
     d  fromLst1                       *   value options(*string)
     d  defaultChc                   10    value
     d  xRefWhat                     10    value options(*nopass)

     d chc             s             10    based(chcPtr)
     d chcPtr          s               *
     d chc1            s             10    based(chcPtr1)
     d chcPtr1         s               *   inz(*null)
     d dft@            s              5  0 inz
     d pLst            s               *
     d pLst1           s               *

      /free
       *in27 = *on;
       write @chcsfc;
       rrna = 0;

       if %parms = 7;
          rrna = rrna + 1;
          @chctx = 'Extern X-reference';
          @scctl = 0;
          write @chcsf;
       endif;

       chcPtr = fromLst;
       chcPtr1 = fromLst1;

       dow chc <> *blank;
          *in27 = *off;
          rrna = rrna + 1;
          @chctx = chc;
          if chcPtr1 <> *null;
             %subst(@chctx: 11: 10) = chc1;
          endif;
          @scctl = 0;
          if defaultChc <> *blank and dft@ = 0 and defaultChc = chc;
             @scctl = 1;
             if %parms = 7;
                dft@ = rrna - 1;
             else;
                dft@ = rrna;
             endif;
          endif;

          write @chcsf;
          chcPtr = chcPtr + 10;
          if chcPtr1 <> *null;
             chcPtr1 = chcPtr1 + 10;
          endif;
       enddo;

       if *in27;
          return 0;
       endif;

       if xpos + 7 + 2 + 1 > 24;
          @ox = 24 - 7 - 2 - 1;
       else;
          @ox = xpos + 1;
       endif;

       if ypos + 26 + 4 + 6 > 132;
          @oy = 132 - 26 - 4 - 6;
       else;
          @oy = ypos + 6;
       endif;
       @chcs = rrna;

       @titl = title;
       dou 1 = 2;
           exfmt @chcsfc;

           dou %eof or @scctl = 1;
               readc @chcsf;
           enddo;

           if %eof;
              return dft@;
           endif;

           if %parms < 7;
              return rrna;
           endif;
           if  rrna > 1;
              return rrna - 1;
           endif;

           callp Xref(fromLst: fromLst1: xRefWhat);
       enddo;
      /end-free
     P GetChc          e

     P ToLevel         b
     d ToLevel         pi             1  0
     d  plastlvl                       *   value
     d  level                         2  0 value

     d pNode           s               *
     d node            ds                  likeds(node_ds) based(pNode)
     d fromPos         s              3  0 static inz(2)

     d levelLink       s               *
     d levelLen        s              2  0 inz(10)
     d ch1st           s              3  0

      /free

       levelLink = plastlvl;

       dow levelLink <> *null;
          pNode = levelLink;

          if node.obj = 'ReferTo';
             pNode = node.up_ref;
          endif;

          if fromPos + 10 > 132;
             return 0;
          endif;

          %subst(@brchs: fromPos: 10) = node.obj;

          pNode = levelLink;

          if node.usage > 0;
             @brchs = %trimr(@brchs) + ',' + %trim(%editc(node.usage: '3'));
             levelLen = 13;
          endif;

          if node.obj <> 'ReferTo' and node.up_ref <> *null and level > 1;
             fromPos = fromPos + levelLen;
             if ToLevel(node.up_ref: level - 1) < 0;
                return -1;
             endif;
             fromPos = fromPos - levelLen;
          else;
             rrn = rrn + 1;

             ch1st = %check(' ': @brchs);
             if ch1st > 2;
                arrTree(rrn) = %subst(arrTree(rrn - 1): 1: ch1st - 1) +
                               %subst(@brchs: ch1st);
             else;
                arrTree(rrn) = @brchs;
             endif;

             write @tree;
             clear @brchs;
          endif;

          levelLink = node.lvllnk;
       enddo;

       return 0;

       /end-free
     P ToLevel         e

     P GetRrn          b
     d GetRrn          pi             5  0
     d  string                      128    value

     d r@              s              5  0

      /free
       for r@ = 1;
           if arrTree(r@) = *blank;
              leave;
           endif;

           if string = arrTree(r@) or
              %len(%trim(string)) < %len(%trim(arrTree(r@))) and
              %scan(%trim(string): arrTree(r@)) = 2 or
              %scan(%trim(arrTree(r@)): string) = 2;
              return r@;
           endif;
       endfor;
       return 0;
      /end-free
     P GetRrn          e

     P WrkObj          b
     d WrkObj          pi
     d  toDo                         10    value options(*nopass)

     d selObj          s             10    static inz
     d curCol          s              3  0 static inz
     d curRrn          s              5  0 static inz(1)
     d layouts         s             26    dim(100) static inz(*hival) ascend

     d topRrn          s              5  0
     d lo@             s              3  0
     d bl@             s              3  0
     d br@             s              3  0

     d objt            s             10
     d objl            s             10
     d mod             s             10
     d modl            s             10
     d srcpf           s             10
     d srcpfl          s             10
     d srcpfm          s             10

     d splfAttr        ds                  likeds(dsSpla0100)
     d qualPgm         s             20
     d dummy           s              1    inz

      /free
       if %parms = 0;
          for lo@ = 1 to 100;
              if layouts(lo@) = *hival;
                 leave;
              endif;
              callp xExeCmd('DLTSPLF FILE(QPRINT) SPLNBR(' +
                            %subst(layouts(lo@): 21) + ')');
          endfor;
          return;
       endif;

       select;
          when toDo = '*RESETSEL';
               selObj = @root;
          when toDo = '*FIND';
               exsr ToFind;
          when toDo = '*LAYOUT';
               exsr DspLayout;
          when toDo = '*DISPLAY';
               exsr DspObject;
          when toDo = '*SOURCE';
               exsr DspSource;
          when toDo = '*SELECT';
               exsr ToSel;
       endsl;

       return;

       begsr DspSource;
          if selObj = @root;
             objt = @roott;
             objl = @rootl;
          else;
             objt = GetObjType(objl: selObj: @csr: @csc + 10);
          endif;

          if objt <> '*PGM' and objt <> '*SRVPGM';
             return;
          endif;

          srcpfm = SelModule(@csr: @csc + 10: objt: selObj + objl:
                             srcpfl: srcpf);

          if srcpfm = *blank;
             return;
          endif;

          MappingSrc(srcpfl);
          xExeCmd('?STRSEU SRCFILE(' + %trim(srcpfl) + '/' +
                  %trim(srcpf) + ') SRCMBR(' + %trim(srcpfm) + ') OPTION(5)');
       endsr;

       begsr DspObject;
          if selObj = @root;
             objt = @roott;
             objl = @rootl;
          else;
             objt = GetObjType(objl: selObj: @csr: @csc + 10);
          endif;

          if objt = '*PGM' or objt = '*SRVPGM';
             mod = SelModule(@csr: @csc + 10: objt: selObj + objl:
                             modl: *omit);
             if mod <> *blank;
                callp xExeCmd('DSPMOD MODULE(' +
                              %trim(modl) + '/' + %trim(mod) + ')');
                return;
             endif;
          endif;

          select;
             when objt = '*PGM';
                  callp xExeCmd('DSPPGM PGM(' +
                        %trim(objl) + '/' + %trim(selObj) + ')');
             when objt = '*FILE';
                  callp xExeCmd('DSPFD FILE(' +
                        %trim(objl) + '/' + %trim(selObj) + ')');
             when objt = '*SRVPGM';
                  callp xExeCmd('DSPSRVPGM SRVPGM(' +
                        %trim(objl) + '/' + %trim(selObj) + ')');
             when objt = '*DTAARA';
                  callp xExeCmd('DSPDTAARA DTAARA(' +
                        %trim(objl) + '/' + %trim(selObj) + ')');
          endsl;
       endsr;

       begsr DspLayout;
          if selObj = @root;
             objt = @roott;
             objl = @rootl;
          else;
             objt = GetObjType(objl: selObj: @csr: @csc + 10);
          endif;

          if objt = '*FILE';
             xExeCmd('DSPFFD FILE(' + %trim(objl) + '/' + %trim(selObj) + ')');

          elseif objt = '*PGM';
             lo@ = %lookupge(selObj + objl: layouts);
             if layouts(lo@) = *hival or
                %subst(layouts(lo@): 1: 20) <> selObj + objl;
                exsr FndSpace;
                exsr InsLayout;
             endif;

             if xExeCmd('DSPSPLF FILE(QPRINT) SPLNBR(' +
                        %subst(layouts(lo@): 21) + ')') <> *blank;
                exsr InsLayout;
                if xExeCmd('DSPSPLF FILE(QPRINT) SPLNBR(' +
                           %subst(layouts(lo@): 21) + ')') <> *blank;
                   @msg = 'Display spool file failed.';
                endif;
             endif;
          endif;
       endsr;

       begsr FndSpace;
             lo@ = %lookup(*hival: layouts);
             if lo@ = 0;
                if xExeCmd('DLTSPLF FILE(QPRINT) SPLNBR(' +
                           %subst(layouts(1): 21) + ')') <> *blank;
                   @msg = 'Delete spool file 1 failed.';
                   return;
                endif;
                lo@ = 1;
             endif;
       endsr;

       begsr InsLayout;
             qualPgm = selObj + objl;
             callp PrtLayout(qualPgm: dummy);

             if xRtvSplfA(%addr(splfAttr): %size(splfAttr): SPLA0100: 'QPRINT')
                <> *blank or splfAttr.usrData <> selObj;
                @msg = 'Print source failed.';
                return;
             endif;

             if splfAttr.splfNbr = 0;
                @msg = 'Print source failed.';
                return;
             endif;

             layouts(lo@) = selObj + objl +
                            %editc(%dec(splfAttr.splfNbr: 6: 0): '3');

             sorta layouts;
             lo@ = %lookupge(selObj + objl: layouts);
       endsr;

       begsr ToSel;
          rrn = @csr - 3 + @csrp - 1;
          chain rrn @tree;
          if %subst(@brchs: @csc - 1: 1) <> *blank;
             exsr ResetScreen;

             rrn = @csr - 3 + topRrn - 1;
             chain rrn @tree;
             for bl@ = @csc - 1 downto 1;
                 if %subst(@brchs: bl@: 1) = *blank;
                    leave;
                 endif;
             endfor;
             br@ = %scan(' ': @brchs: @csc - 1);
             if bl@ > 0 and br@ > 0;
                if curRrn = @csr - 3 + topRrn - 1 and curCol = bl@ + 1;
                   selObj = @root;
                   curRrn = topRrn;
                   curCol = 0;
                else;
                   selObj = %subst(@brchs: bl@ + 1: br@ - bl@ - 1);
                   if %scan(',': selObj) > 0;
                      selObj = %subst(selObj: 1: %scan(',': selObj) - 1);
                   endif;
                   %subst(@brchs: bl@: 1) = x'21';
                   %subst(@brchs: br@: 1) = x'20';
                   update @tree;
                   curRrn = @csr - 3 + topRrn - 1;
                   curCol = bl@ + 1;
                endif;
             endif;
          endif;
       endsr;

       begsr ToFind;
          if selObj = @root;
             callp GetInp(@csr: @csc: 'Find:');
             if @input = *blank;
                @msg = 'Find what?';
                return;
             endif;
          endif;

          exsr ResetScreen;
          if curRrn < topRrn;
             curRrn = topRrn;
          endif;

          for curRrn;
              if curRrn > totRrn;
                 if topRrn > 0;
                    topRrn = 0;
                    curRrn = 1;
                 else;
                    @msg = 'Object not found.';
                    return;
                 endif;
              endif;

              chain curRrn @tree;

              if selObj = @root;
                 curCol = %scan(%trim(@input): @brchs: curCol + 1);
              else;
                 curCol = %scan(%trim(selObj): @brchs: curCol + 1);
              endif;

              if curCol > 1 and %subst(@brchs: curCol - 1: 1) = ' ';
                 if selObj = @root;
                    selObj = @input;
                 endif;

                 if %scan(',': selObj) > 0;
                    selObj = %subst(selObj: 1: %scan(',': selObj) - 1);
                 endif;

                 %subst(@brchs: curCol - 1: 1) = x'21';
                 %subst(@brchs: %scan(' ': @brchs: curCol): 1) = x'20';
                 update @tree;

                 if topRrn = 0;
                    topRrn = 1;
                 endif;
                 dow curRrn >= topRrn + 20;
                     topRrn = topRrn + 20;
                 enddo;

                 @csrp = topRrn;
                 leave;
              endif;

              curCol = 0;
          endfor;
       endsr;

       begsr ResetScreen;
          topRrn = @csrp;
          if curCol > 0 and curRrn > 0 and curRrn <= totRrn;
             chain curRrn @tree;
             for bl@ = curCol downto 1;
                 if %subst(@brchs: bl@: 1) = x'21';
                    leave;
                 endif;
             endfor;
             br@ = %scan(x'20': @brchs: curCol);
             if bl@ > 0 and br@ > 0;
                %subst(@brchs: bl@: 1) = *blank;
                %subst(@brchs: br@: 1) = *blank;
                update @tree;
             else;
                curRrn = topRrn;
                curCol = 0;
             endif;
          endif;
       endsr;
      /end-free
     P WrkObj          e

     P WrkSch          b
     d WrkSch          pi              n
     d  phase                         3    value

     d arrSchIn        s             10    dim(9999) static inz
     d csrrow          s              4b 0 inz
     d csrcol          s              4b 0 inz
     d r@              s              4b 0
     d c@              s              4b 0
     d clickOnLf       s             10    inz
      /free

       if phase = 'INZ';
          clear @sbxc;
          @sbxstyle = 1;
          @sbxcases = 0;

          *in37 = *on;
          write @sbxc;
          *in37 = *off;
          exsr EmptyBox;

          clear arrSchIn;
          @msg = 'Click or Enter on names to create "Search in" list. Press F1 +
                  to start, F12 to cancel.';
          return *on;
       endif;

       if phase = 'CNL';
          return *off;
       endif;

       if phase = 'CFM';
          if @sbxfor = *blank;
             @msg = '"Search for" needed.';
             return *on;
          endif;

          for rrnb = 1 to @sbxsz;
              chain rrnb @sbx;
              if @sbxpfm = *blank;
                 @msg = '"Search in" list needed.';
                 return *on;
              endif;
              SearchFor(@sbxfor: @sbxslb: @sbxspf: @sbxpfm:
                        @sbxstyle: @sbxcases);
          endfor;

          if @sbxstyle = 2;
             SearchFor();
          endif;
          return *off;
       endif;

       if phase = 'SEL';
          exsr LocateCursor;
          if csrrow = 0 and csrcol = 0;     //invalid click
             @msg = 'Press F1 to start, F12 to cancel.';
             return *on;
          endif;

          if csrrow = 0;                    //click on root
             if @roott = '*PGM';
                exsr OnCursor;
             elseif @roott = '*FILE';
                csrrow = 1;                 //lookup 1st&2nd level
             else;
                @msg = 'The root is not a file or a program.';
                return *on;                 //root no good for search
             endif;
          endif;

          if csrcol <= 2;                   //on root *FILE or 1st level
             c@ = 0;

             for r@ = csrrow;
                 if csrcol = 1 and arrTree(r@) = *blank or                     /
                    csrcol = 2 and r@ > csrrow and                             /
                    %subst(arrTree(r@): 2: 10) <> clickOnLf;
                    leave;
                 endif;

                 if c@ = 0;
                    c@ = %scan(',': arrTree(r@));             //find usage
                    if c@ = 0 and csrcol = 1;             //click on root *FILE,
                       iter;
                    endif;

                    if c@ = 0 and csrcol = 2 or                //click on 1st le
                       c@ > 0 and c@ < %scan(' ': arrTree(r@): csrcol);    //w/
                       exsr OnCursor;                          //1st level not f
                    endif;
                                                       //c@ > 0;
                    if csrcol = 2 and r@ = csrrow;
                       clickOnLf = %subst(arrTree(r@): 2: 10);
                    endif;

                    dou %subst(arrTree(r@): c@: 1) = *blank;
                        c@ = c@ - 1;
                    enddo;
                    c@ = c@ + 1;
                 endif;

                 if %subst(arrTree(r@): c@: 1) = *blank;
                    iter;
                 endif;

                 exsr OnRowCol;
             endfor;

             if rrnb = 0;
                exsr EmptyBox;
             else;
                @sbxsz = rrnb;
             endif;

             @msg = 'Press F1 to start, F12 to cancel.';
             return *on;

          else;                             //on 2nd and above level
            exsr OnCursor;
          endif;
       endif;

       begsr EmptyBox;
          rrnb = 1;
          clear @sbx;
          write @sbx;
          @sbxcs = rrnb;
          @sbxsz = 1;
       endsr;

       begsr LocateCursor;
          if @csr = 1 and @csc >= 2 and @csc <= 11 and
             @csc <= %scan(' ': @root);                  //click on root
             csrcol = 1;

          elseif @csr > 3 and @csc >= 3 and @csc < 114;
             csrrow = @csr - 3 + @csrp - 1;
             csrcol = @csc - 1;
             dow %subst(arrTree(csrrow): csrcol: 1) <> *blank;
                 csrcol = csrcol - 1;
             enddo;
             if csrcol = @csc - 1;
                csrrow = 0;
                csrcol = 0;
             else;
                csrcol = csrcol + 1;
             endif;
          endif;
       endsr;

       begsr OnCursor;
          if csrrow = 0;          //root
             @sbxsfr = @root;
          elseif %scan(',': arrTree(csrrow): csrcol) > csrcol;
             @sbxsfr = %subst(arrTree(csrrow): csrcol:
                             %scan(',': arrTree(csrrow): csrcol) - csrcol);
          elseif %scan(' ': arrTree(csrrow): csrcol) > csrcol;
             @sbxsfr = %subst(arrTree(csrrow): csrcol:
                             %scan(' ': arrTree(csrrow): csrcol) - csrcol);
          else;
             @sbxsfr = %subst(arrTree(csrrow): csrcol: 10);
          endif;

          exsr AddSbx;

          if rrnb = 0;
             exsr EmptyBox;
          else;
             @sbxsz = rrnb;
          endif;
          @msg = 'Press F1 to start, F12 to cancel.';
          return *on;
       endsr;

       begsr OnRowCol;
          if %scan(',': arrTree(r@): c@) > c@;
             @sbxsfr = %subst(arrTree(r@): c@:
                              %scan(',': arrTree(r@): c@) - c@);
          endif;

          exsr AddSbx;
       endsr;

       begsr AddSbx;
          if rrnb = 1 and arrSchIn(1) = *blank;
             *in37 = *on;
             write @sbxc;
             *in37 = *off;
             rrnb = 0;
          endif;

          if %lookup(@sbxsfr: arrSchIn) = 0;
             if @sbxsfr = @root;
                @sbxpfm = @roott;
                @sbxslb = @rootl;
             else;
                @sbxpfm = GetObjType(@sbxslb: @sbxsfr: @csr: @csc + 10);     //t
             endif;

             if @sbxpfm = '*PGM' or @sbxpfm = '*SRVPGM';
                @sbxpfm = SelModule(@csr: @csc + 10:
                                    @sbxpfm: @sbxsfr + @sbxslb:
                                    @sbxslb: @sbxspf);     //pfm=..(x:y:otype:o+

                if @sbxpfm <> *blank;
                   MappingSrc(@sbxslb);

                   rrnb = rrnb + 1;
                   arrSchIn(rrnb) = @sbxsfr;
                   write @sbx;
                   @sbxcs = rrnb;
                endif;
             endif;
          endif;
       endsr;

      /end-free
     P WrkSch          e

     P SearchFor       b
     d SearchFor       pi
     d  string                             like(@sbxfor) value options(*nopass)
     d  pflib                        10    value options(*nopass)
     d  pf                           10    value options(*nopass)
     d  pfm                          10    value options(*nopass)
     d  style                         2  0 value options(*nopass)
     d  casesense                     2  0 value options(*nopass)

     d cmd             s           1024    varying
     d splfAttr        ds                  likeds(dsSpla0100)
      /free

       if %parms = 0;
          if xExeCmd('DSPPFM FILE(QTEMP/' + %trim(psds.prc_name) + ')')
             <> *blank;
             @msg = 'Collect search result error.';
             return;
          endif;

          GetInp(@csr: @csc: 'Save?');
          if @input = 'YES' and
             xExeCmd('CPYF FROMFILE(QTEMP/' + %trim(psds.prc_name) + ') +
                           TOFILE(*PRINT)') <> *blank;
             @msg = 'Save collected search result error.';
             return;
          endif;

          return;
       endif;

       cmd = 'FNDSTRPDM STRING(''' + %trim(string) + ''') +
              FILE(' + %trim(pflib) + '/' + %trim(pf) + ') +
              MBR(' + %trim(pfm) + ')';

       if style = 2;     //show all
          cmd = cmd + ' OPTION(*NONE) PRTRCDS(*ALL *CHAR *NOMARK)';
       else;                                  //show each or default
          cmd = cmd + ' OPTION(*DSP)';
       endif;

       if casesense = 1;         //case sensitive
          cmd = cmd + ' CASE(*MATCH)';
       endif;

       if (xExeCmd(cmd) = *blank or xExeCmd('?' + cmd) = *blank) and
          style = 2;
          xRtvSplfA(%addr(splfAttr): %size(splfAttr): SPLA0100: 'QPUOPRTF');

          if xExeCmd('CHKOBJ OBJ(QTEMP/' + %trim(psds.prc_name) + ') +
                             OBJTYPE(*FILE)') = 'CPF9801';
             xExeCmd('CRTPF FILE(QTEMP/' + %trim(psds.prc_name) + ') +
                   RCDLEN(132)');
          endif;

          if xExeCmd('CPYSPLF FILE(QPUOPRTF) +
                              TOFILE(QTEMP/' + %trim(psds.prc_name) + ') +
                              SPLNBR(' + %char(splfAttr.splfNbr) + ') +
                              MBROPT(*ADD)') <> *blank;
             @msg = 'Collect search result error.';
             return;
          endif;

          xExeCmd('DLTSPLF FILE(QPUOPRTF) +
                           SPLNBR(' + %char(splfAttr.splfNbr) + ')');
       endif;

       return;

      /end-free
     P SearchFor       e

     P ExtActGrp       b
      /free

       WrkObj();
       xExeCmd('DLTF FILE(QTEMP/' + %trim(psds.prc_name) + ')');

       return;

      /end-free
     P ExtActGrp       e
** objTypes
*PGM      P
*FILE     F
*SRVPGM
*DTAARA   D
