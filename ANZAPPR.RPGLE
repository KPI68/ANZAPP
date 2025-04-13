     H dftactgrp(*no) actgrp(*new) bnddir('ANZAPPR') debug

     fAnzapp90  uf a e           k disk    usropn
     fAnzappf   cf   e             workstn sfile(ktree: rrn) usropn
     f                                     sfile(kchcsf: rrna) infds(forevent)
     f                                     sfile(ksbx: rrnb)

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

     D*SetupHbch       pr
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
     d  string                             like(ksbxfor) value options(*nopass)
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
     d csrc§                   2      2
     d csr§                    1      2b 0 inz
     d                 ds
     d cscc§                   2      2
     d csc§                    1      2b 0 inz

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
       // SetupHbch();
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

       dou kmnbfld = 1 and kfile = 90;
          write kmsgl;
          write kmnubr;
          read kmnubr;
          kmsg = *blank;

          select;
             when kmnbfld = 1;
                read kpulld1;

                if kfile = 90; //exit
                   leave;
                endif;

                if kfile = 11 and f9apps = *blank;    //renew
                   kmsg = 'Open an application first.';
                   iter;
                endif;

                exsr SrPullD1;

             when kmnbfld = 2;
                read kpulld2;            // up/down

                if klink = 0;
                   iter;
                endif;

                if f9apps = *blank;
                   kmsg = 'Open an application first.';
                   iter;
                endif;

                exsr SrPullD2;

             when kmnbfld = 3;
                read kpulld3;
                if kabout = 1;
                   DspHelp();
                elseif kabout = 2;
                   kax = kcx3;
                   kay = kcy3 + 6;
                   exfmt kabtwnd;
                endif;
          endsl;
       enddo;

       close Anzapp90;
       close Anzappf;
       return;

       begsr SrPullD1;
          select;
             when kfile = 1 or kfile = 2 and appLst.names(1) = *blank; // new -
                callp GetInp(kcx1: kcy1: 'System:');

                if kinput <> *blank;
                   callp SetAppSys(kinput);
                   callp SetAppLst();
                endif;

             when kfile = 2;                                     // open
                chain psds.job_user Anzapp90;
                if %found(Anzapp90);
                   f9apps = appLst.names(GetChc('  App System  ': kcx1: kcy1:
                                                %addr(appLst): *null: f9apps));
                   update R90;
                else;
                   f9apps = appLst.names(GetChc('  App System  ': kcx1: kcy1:
                                                %addr(appLst): *null:
                                                appLst.names(1)));
                   write R90;
                endif;

             when kfile = 11;                                    // renew
                callp SetAppSys(f9apps:
                                appLst.descs(%lookup(f9apps: appLst.names)));

             when kfile = 21;                                    // set exemptio
                callp SetExempt();

             when kfile = 22;
                  SetMapSrcLib();

             when kfile = 31;
                callp ChgFileUsage();
          endsl;
       endsr;

       begsr SrPullD2;
          if klink = 1;
             backward = *off;
          elseif klink = 2;
             backward = *on;
          endif;
          exsr LinkUp;
       endsr;

       begsr LinkUp;
          dou *inKL or kpsbtfd = 1;  //CA12
              if kroot = *blank;
                 callp GetInp(kcx2: kcy2: 'From:');
                 if kinput = *blank;
                    leave;
                 endif;

                 kroot = kinput;

                 if kroot = '*VARIABLE';
                    kroott = 'P';
                 endif;

                 if f9apps = 'HUB8_BCH';
                    kroott = '*HUBBCH';
                 endif;

                 if kroott = *blank;
                    kroott = GetObjType(krootl: kroot: kwx: kwy + 10);
                    if kroott = *blank;
                       kmsg = %trim(kroot) + ' with type *FILE/*PGM/*SRVPGM/*D+
                              TAARA not found.';
                       leave;
                    elseif kroott = '*FILE' and backward;
                       kmsg = %trim(kroot) + ' is a file, not applicable to +
                              program references.';
                       leave;
                    endif;
                 endif;
                 level = 1;
              endif;

              *in91 = *on;
              write ktreec;
              *in91 = *off;
              kmsg = *blank;
              rrn = 0;

              clear kbrchs;
              clear arrTree;

              if (kroott = '*FILE' or backward) and
                 ToLevel(GetRoot(f9apps: kroot: krootl: entryParm): level) = 0
                 or kroott <> '*FILE' and not backward and
                 ToLevel(GetRoot(f9apps: kroot: krootl: kroott): level) = 0;
                 totRrn = rrn;
                 if rrn > 0;
                    if kfrlsp = *blank;
                       kcsrp = 1;
                    else;
                       kcsrp = GetRrn(kfrlsp);
                    endif;
                 else;
                    rrn = 1;
                    clear kbrchs;
                    write ktree;
                 endif;
              endif;

              callp WrkObj('*RESETSEL');

              dou *inKL or kpsbtfd = 1; //CA12
                  if kcsrp <= 0 or kcsrp > totRrn;
                    kcsrp = 1;
                  endif;
                  if totRrn > 0;
                     kfrlsp = arrTree(kcsrp);             //show the good one
                  endif;

                 write kmsgl;

                 if duringSearch;
                    exfmt ksbxc;
                 else;
                    exfmt ktreec;

                    kcsrp = kcsrg;
                    if totRrn > 0;
                       kfrlsp = arrTree(kcsrp);             //save for --> and <
                    endif;
                 endif;

                 csrc§ = csr_row;
                 cscc§ = csr_col;
                 kmsg = *blank;

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

                 when *inKL or kpsbtfd = 1;   //F12
                      leave;

                 when *inKE or kpsbtfd = 2;   //F5
                      level = 1;
                      clear kroot;
                      clear kroott;
                      clear kfrlsp;
                      leave;

                 when (*inKQ or kpsbtfd = 3) and totRrn > 0;                  //
                      callp WrkObj('*FIND');

                 when (*inKT or kpsbtfd = 4) and level > 1;     //F19
                      level = level - 1;
                      leave;

                 when (*inKU or kpsbtfd = 9) and level < 11 and totRrn > 0;   //
                      level = level + 1;
                      leave;

                 when *inKV or kpsbtfd = 5;               //F21
                      callp qCmd();

                 when *inKW or kpsbtfd = 6;               //F22
                      callp WrkObj('*LAYOUT');

                 when *inKX or kpsbtfd = 7;               //F23
                      callp WrkObj('*DISPLAY');

                 when *inKY or kpsbtfd = 8;               //F24
                      callp WrkObj('*SOURCE');

                 when (*inKR or kpsbtfd = 10) and totRrn > 0;     //F17
                      duringSearch = WrkSch('INZ');

                 when mouse_event = x'F1' and                     //mouse click
                      csr§ > 3 and csc§ > 1 and csc§ < 130 and totRrn > 0;
                      WrkObj('*SELECT');
                 endsl;
              enddo;
          enddo;

          clear kroot;
          clear kroott;
          clear kfrlsp;
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
          kmsg = 'Edit object libraries error.';
          return;
       endif;

       GetInp(kcx1: kcy1: 'Sure?');
       if kinput <> 'YES';
          return;
       endif;

       if apps = 'HUB8_BCH';
          if xExeCmd('SBMJOB CMD(CALL PGM(ANZAPPR)) +
                      JOB(ANZAPP) JOBQ(QBATCH)') <> *blank;
             kmsg = 'Anzapp job submit error.';
             return;
          endif;

          kmsg = 'Job submitted to set up Xreference for the application, +
                 please check job log when finished.';
          return;
       endif;

       if xExeCmd('SBMJOB CMD(CALL PGM(ANZAPPR) PARM(' +
                  x'7d' + %trim(apps) + x'7d' +
                  ')) JOB(ANZAPP) JOBQ(QBATCH)') <> *blank;
          kmsg = 'Anzapp job submit error.';
          return;
       endif;

       kmsg = 'Job submitted to set up Xreference for the application, +
              please check job log when finished.';

       return;
      /end-free
     P SetAppSys       e

     P SetExempt       b
     d SetExempt       pi
      /free
       if xExeCmd('UPDDTA FILE(ANZAPP10)') <> *blank;
          kmsg = 'Set up exempted object fail.';
       else;
          kmsg = 'Restart the command to apply the new setting.';
       endif;

       return;
      /end-free
     P SetExempt       e

     P SetMapSrcLib    b
     d SetMapSrcLib    pi
      /free
       if xExeCmd('UPDDTA FILE(ANZAPP20)') <> *blank;
          kmsg = 'Set up mapping source library fail.';
       else;
          kmsg = 'Restart the command to apply the new setting.';
       endif;

       return;
      /end-free
     P SetMapSrcLib    e

     P SetAppLst       b
     d SetAppLst       pi

     d alk             s              3  0
     d etk             s              3  0
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

       alk = 0;
       for etk = 1 to nbrEntry;
          if lst.type = 'OBJLIBS';
             alk = alk + 1;
             appLst.Names(alk) = lst.name;
             appLst.Descs(alk) = lst.text;
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
       rtnChc = GetChc('  File Usage  ': kcx3: kcy3:
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
     d lst             ds                  likeds(dsPGML0100) based(ptrk)
     d ptrk            s               *
     d savLst          ds                  likeds(dsPGML0100) based(savPtrk)
     d savPtrk         s               *
     d nEnt            s              9b 0
     d szEnt           s              9b 0
     d entk            s              9b 0
     d rtnModk         s              5  0

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

          ptrk = lstPtr;

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

          for entk = 1 to nEnt;
              modLst(entk) = lst.mod;
              libLst(entk) = lst.modl;
              ptrk = ptrk + szEnt;
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

          ptrk = lstPtr;
          clear modLst;
          clear libLst;
          entk = 0;

          if %addr(srcpf) <> *null;
             entk = entk + 1;
             modLst(entk) = 'Export';
             libLst(entk) = 'Source';
          endif;

          for entk = 1 to nEnt;
              modLst(entk) = lst.mod;
              libLst(entk) = lst.modl;
              ptrk = ptrk + szEnt;
          endfor;
       endif;

       exsr SetSavLst;

       rtnModk = GetChc(' Sel Modules  ': xpos: ypos:
                        %addr(modLst): %addr(libLst): *blank:
                        'ModExtXref');

       if rtnModk = 0;
          exsr RlsSavLst;
          return *blank;
       endif;

       if %addr(srcpf) = *null;
          lib = libLst(rtnModk);
          exsr RlsSavLst;
          return modLst(rtnModk);
       endif;

       //if objType = '*SRVPGM' and rtnModk = 1;
       //   srcpf = spgInf.srcpf;
       //   lib = spgInf.srcpfl;
       //   exsr RlsSavLst;
       //   return spgInf.srcpfm;
       //endif;

       ptrk = savLstPtr;
       for entk = 1 to nEnt;
           if lst.mod = modLst(rtnModk);
              srcpf = lst.srcpf;
              lib = lst.srcpfl;
              return lst.srcpfm;
           endif;
           ptrk = ptrk + szEnt;
       endfor;

       exsr RlsSavLst;
       return *blank;

       begsr SetSavLst;
          savLstPtr = %alloc(nEnt * szEnt);
          ptrk = lstPtr;
          savPtrk = savLstPtr;
          for entk = 1 to nEnt;
              savLst = lst;
              ptrk = ptrk + szEnt;
              savPtrk = savPtrk + szEnt;
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
     d rtk             s              2  0
     d otk             s              2  0
     d dftk            s              2  0 inz
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
          if kinput = *blank;
             return *blank;
          endif;
          lstPtr = xLstObj(nbrEnt: szEnt: OBJL0100: obj + kinput);
          if lstPtr = *null or nbrEnt <= 0;
             return *blank;
          endif;
       endif;

       objlib = *blank;
       clear typesGot;
       clear libsGot;

       rtk = 0;
       for nbrEnt = nbrEnt downto 1;
          otk = %lookup(objLst.type: objTypes);
          if otk > 0;
             if dftk = 0 or otk < dftk;
                dftk = otk;
             endif;
             rtk = rtk + 1;
             if rtk > 40;
                return *blank;
             endif;
             typesGot(rtk) = objLst.type;
             libsGot(rtk) = objLst.lib;
          endif;
          lstPtr = lstPtr + szEnt;
       endfor;

       if rtk = 0;
          return *blank;
       endif;

       if rtk = 1;
          objlib = libsGot(1);
          return typesGot(1);
       endif;

       rtnChc = GetChc('Dup ' + %trim(obj): xpos: ypos:
                       %addr(typesGot): %addr(libsGot): objTypes(dftk));

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
          kwx = 24 - 2 - 2;
       else;
          kwx = xpos;
       endif;

       if ypos + 6 + 18 + 4 > 132;
          kwy = 132 - 18 - 4 - 6;
       else;
          kwy = ypos + 6;
       endif;

       kprompt = prompt;
       exfmt kinpwnd;
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
     d dftk            s              5  0 inz
     d pLst            s               *
     d pLst1           s               *

      /free
       *in27 = *on;
       write kchcsfc;
       rrna = 0;

       if %parms = 7;
          rrna = rrna + 1;
          kchctx = 'Extern X-reference';
          kscctl = 0;
          write kchcsf;
       endif;

       chcPtr = fromLst;
       chcPtr1 = fromLst1;

       dow chc <> *blank;
          *in27 = *off;
          rrna = rrna + 1;
          kchctx = chc;
          if chcPtr1 <> *null;
             %subst(kchctx: 11: 10) = chc1;
          endif;
          kscctl = 0;
          if defaultChc <> *blank and dftk = 0 and defaultChc = chc;
             kscctl = 1;
             if %parms = 7;
                dftk = rrna - 1;
             else;
                dftk = rrna;
             endif;
          endif;

          write kchcsf;
          chcPtr = chcPtr + 10;
          if chcPtr1 <> *null;
             chcPtr1 = chcPtr1 + 10;
          endif;
       enddo;

       if *in27;
          return 0;
       endif;

       if xpos + 7 + 2 + 1 > 24;
          kox = 24 - 7 - 2 - 1;
       else;
          kox = xpos + 1;
       endif;

       if ypos + 26 + 4 + 6 > 132;
          koy = 132 - 26 - 4 - 6;
       else;
          koy = ypos + 6;
       endif;
       kchcs = rrna;

       ktitl = title;
       dou 1 = 2;
           exfmt kchcsfc;

           dou %eof or kscctl = 1;
               readc kchcsf;
           enddo;

           if %eof;
              return dftk;
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

          %subst(kbrchs: fromPos: 10) = node.obj;

          pNode = levelLink;

          if node.usage > 0;
             kbrchs = %trimr(kbrchs) + ',' + %trim(%editc(node.usage: '3'));
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

             ch1st = %check(' ': kbrchs);
             if ch1st > 2;
                arrTree(rrn) = %subst(arrTree(rrn - 1): 1: ch1st - 1) +
                               %subst(kbrchs: ch1st);
             else;
                arrTree(rrn) = kbrchs;
             endif;

             write ktree;
             clear kbrchs;
          endif;

          levelLink = node.lvllnk;
       enddo;

       return 0;

       /end-free
     P ToLevel         e

     P GetRrn          b
     d GetRrn          pi             5  0
     d  string                      128    value

     d rk              s              5  0

      /free
       for rk = 1;
           if arrTree(rk) = *blank;
              leave;
           endif;

           if string = arrTree(rk) or
              %len(%trim(string)) < %len(%trim(arrTree(rk))) and
              %scan(%trim(string): arrTree(rk)) = 2 or
              %scan(%trim(arrTree(rk)): string) = 2;
              return rk;
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
     d lok             s              3  0
     d blk             s              3  0
     d brk             s              3  0

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
          for lok = 1 to 100;
              if layouts(lok) = *hival;
                 leave;
              endif;
              callp xExeCmd('DLTSPLF FILE(QPRINT) SPLNBR(' +
                            %subst(layouts(lok): 21) + ')');
          endfor;
          return;
       endif;

       select;
          when toDo = '*RESETSEL';
               selObj = kroot;
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
          if selObj = kroot;
             objt = kroott;
             objl = krootl;
          else;
             objt = GetObjType(objl: selObj: csr§: csc§ + 10);
          endif;

          if objt <> '*PGM' and objt <> '*SRVPGM';
             return;
          endif;

          srcpfm = SelModule(csr§: csc§ + 10: objt: selObj + objl:
                             srcpfl: srcpf);

          if srcpfm = *blank;
             return;
          endif;

          MappingSrc(srcpfl);
          xExeCmd('?STRSEU SRCFILE(' + %trim(srcpfl) + '/' +
                  %trim(srcpf) + ') SRCMBR(' + %trim(srcpfm) + ') OPTION(5)');
       endsr;

       begsr DspObject;
          if selObj = kroot;
             objt = kroott;
             objl = krootl;
          else;
             objt = GetObjType(objl: selObj: csr§: csc§ + 10);
          endif;

          if objt = '*PGM' or objt = '*SRVPGM';
             mod = SelModule(csr§: csc§ + 10: objt: selObj + objl:
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
          if selObj = kroot;
             objt = kroott;
             objl = krootl;
          else;
             objt = GetObjType(objl: selObj: csr§: csc§ + 10);
          endif;

          if objt = '*FILE';
             xExeCmd('DSPFFD FILE(' + %trim(objl) + '/' + %trim(selObj) + ')');

          elseif objt = '*PGM';
             lok = %lookupge(selObj + objl: layouts);
             if layouts(lok) = *hival or
                %subst(layouts(lok): 1: 20) <> selObj + objl;
                exsr FndSpace;
                exsr InsLayout;
             endif;

             if xExeCmd('DSPSPLF FILE(QPRINT) SPLNBR(' +
                        %subst(layouts(lok): 21) + ')') <> *blank;
                exsr InsLayout;
                if xExeCmd('DSPSPLF FILE(QPRINT) SPLNBR(' +
                           %subst(layouts(lok): 21) + ')') <> *blank;
                   kmsg = 'Display spool file failed.';
                endif;
             endif;
          endif;
       endsr;

       begsr FndSpace;
             lok = %lookup(*hival: layouts);
             if lok = 0;
                if xExeCmd('DLTSPLF FILE(QPRINT) SPLNBR(' +
                           %subst(layouts(1): 21) + ')') <> *blank;
                   kmsg = 'Delete spool file 1 failed.';
                   return;
                endif;
                lok = 1;
             endif;
       endsr;

       begsr InsLayout;
             qualPgm = selObj + objl;
             callp PrtLayout(qualPgm: dummy);

             if xRtvSplfA(%addr(splfAttr): %size(splfAttr): SPLA0100: 'QPRINT')
                <> *blank or splfAttr.usrData <> selObj;
                kmsg = 'Print source failed.';
                return;
             endif;

             if splfAttr.splfNbr = 0;
                kmsg = 'Print source failed.';
                return;
             endif;

             layouts(lok) = selObj + objl +
                            %editc(%dec(splfAttr.splfNbr: 6: 0): '3');

             sorta layouts;
             lok = %lookupge(selObj + objl: layouts);
       endsr;

       begsr ToSel;
          rrn = csr§ - 3 + kcsrp - 1;
          chain rrn ktree;
          if %subst(kbrchs: csc§ - 1: 1) <> *blank;
             exsr ResetScreen;

             rrn = csr§ - 3 + topRrn - 1;
             chain rrn ktree;
             for blk = csc§ - 1 downto 1;
                 if %subst(kbrchs: blk: 1) = *blank;
                    leave;
                 endif;
             endfor;
             brk = %scan(' ': kbrchs: csc§ - 1);
             if blk > 0 and brk > 0;
                if curRrn = csr§ - 3 + topRrn - 1 and curCol = blk + 1;
                   selObj = kroot;
                   curRrn = topRrn;
                   curCol = 0;
                else;
                   selObj = %subst(kbrchs: blk + 1: brk - blk - 1);
                   if %scan(',': selObj) > 0;
                      selObj = %subst(selObj: 1: %scan(',': selObj) - 1);
                   endif;
                   %subst(kbrchs: blk: 1) = x'21';
                   %subst(kbrchs: brk: 1) = x'20';
                   update ktree;
                   curRrn = csr§ - 3 + topRrn - 1;
                   curCol = blk + 1;
                endif;
             endif;
          endif;
       endsr;

       begsr ToFind;
          if selObj = kroot;
             callp GetInp(csr§: csc§: 'Find:');
             if kinput = *blank;
                kmsg = 'Find what?';
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
                    kmsg = 'Object not found.';
                    return;
                 endif;
              endif;

              chain curRrn ktree;

              if selObj = kroot;
                 curCol = %scan(%trim(kinput): kbrchs: curCol + 1);
              else;
                 curCol = %scan(%trim(selObj): kbrchs: curCol + 1);
              endif;

              if curCol > 1 and %subst(kbrchs: curCol - 1: 1) = ' ';
                 if selObj = kroot;
                    selObj = kinput;
                 endif;

                 if %scan(',': selObj) > 0;
                    selObj = %subst(selObj: 1: %scan(',': selObj) - 1);
                 endif;

                 %subst(kbrchs: curCol - 1: 1) = x'21';
                 %subst(kbrchs: %scan(' ': kbrchs: curCol): 1) = x'20';
                 update ktree;

                 if topRrn = 0;
                    topRrn = 1;
                 endif;
                 dow curRrn >= topRrn + 20;
                     topRrn = topRrn + 20;
                 enddo;

                 kcsrp = topRrn;
                 leave;
              endif;

              curCol = 0;
          endfor;
       endsr;

       begsr ResetScreen;
          topRrn = kcsrp;
          if curCol > 0 and curRrn > 0 and curRrn <= totRrn;
             chain curRrn ktree;
             for blk = curCol downto 1;
                 if %subst(kbrchs: blk: 1) = x'21';
                    leave;
                 endif;
             endfor;
             brk = %scan(x'20': kbrchs: curCol);
             if blk > 0 and brk > 0;
                %subst(kbrchs: blk: 1) = *blank;
                %subst(kbrchs: brk: 1) = *blank;
                update ktree;
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
     d rk              s              4b 0
     d ck              s              4b 0
     d clickOnLf       s             10    inz
      /free

       if phase = 'INZ';
          clear ksbxc;
          ksbxstyle = 1;
          ksbxcases = 0;

          *in37 = *on;
          write ksbxc;
          *in37 = *off;
          exsr EmptyBox;

          clear arrSchIn;
          kmsg = 'Click or Enter on names to create "Search in" list. Press F1 +
                  to start, F12 to cancel.';
          return *on;
       endif;

       if phase = 'CNL';
          return *off;
       endif;

       if phase = 'CFM';
          if ksbxfor = *blank;
             kmsg = '"Search for" needed.';
             return *on;
          endif;

          for rrnb = 1 to ksbxsz;
              chain rrnb ksbx;
              if ksbxpfm = *blank;
                 kmsg = '"Search in" list needed.';
                 return *on;
              endif;
              SearchFor(ksbxfor: ksbxslb: ksbxspf: ksbxpfm:
                        ksbxstyle: ksbxcases);
          endfor;

          if ksbxstyle = 2;
             SearchFor();
          endif;
          return *off;
       endif;

       if phase = 'SEL';
          exsr LocateCursor;
          if csrrow = 0 and csrcol = 0;     //invalid click
             kmsg = 'Press F1 to start, F12 to cancel.';
             return *on;
          endif;

          if csrrow = 0;                    //click on root
             if kroott = '*PGM';
                exsr OnCursor;
             elseif kroott = '*FILE';
                csrrow = 1;                 //lookup 1st&2nd level
             else;
                kmsg = 'The root is not a file or a program.';
                return *on;                 //root no good for search
             endif;
          endif;

          if csrcol <= 2;                   //on root *FILE or 1st level
             ck = 0;

             for rk = csrrow;
                 if csrcol = 1 and arrTree(rk) = *blank or
                    csrcol = 2 and rk > csrrow and
                    %subst(arrTree(rk): 2: 10) <> clickOnLf;
                    leave;
                 endif;

                 if ck = 0;
                    ck = %scan(',': arrTree(rk));             //find usage
                    if ck = 0 and csrcol = 1;             //click on root *FILE,
                       iter;
                    endif;

                    if ck = 0 and csrcol = 2 or                //click on 1st le
                       ck > 0 and ck < %scan(' ': arrTree(rk): csrcol);    //w/
                       exsr OnCursor;                          //1st level not f
                    endif;
                                                       //ck > 0;
                    if csrcol = 2 and rk = csrrow;
                       clickOnLf = %subst(arrTree(rk): 2: 10);
                    endif;

                    dou %subst(arrTree(rk): ck: 1) = *blank;
                        ck = ck - 1;
                    enddo;
                    ck = ck + 1;
                 endif;

                 if %subst(arrTree(rk): ck: 1) = *blank;
                    iter;
                 endif;

                 exsr OnRowCol;
             endfor;

             if rrnb = 0;
                exsr EmptyBox;
             else;
                ksbxsz = rrnb;
             endif;

             kmsg = 'Press F1 to start, F12 to cancel.';
             return *on;

          else;                             //on 2nd and above level
            exsr OnCursor;
          endif;
       endif;

       begsr EmptyBox;
          rrnb = 1;
          clear ksbx;
          write ksbx;
          ksbxcs = rrnb;
          ksbxsz = 1;
       endsr;

       begsr LocateCursor;
          if csr§ = 1 and csc§ >= 2 and csc§ <= 11 and
             csc§ <= %scan(' ': kroot);                  //click on root
             csrcol = 1;

          elseif csr§ > 3 and csc§ >= 3 and csc§ < 114;
             csrrow = csr§ - 3 + kcsrp - 1;
             csrcol = csc§ - 1;
             dow %subst(arrTree(csrrow): csrcol: 1) <> *blank;
                 csrcol = csrcol - 1;
             enddo;
             if csrcol = csc§ - 1;
                csrrow = 0;
                csrcol = 0;
             else;
                csrcol = csrcol + 1;
             endif;
          endif;
       endsr;

       begsr OnCursor;
          if csrrow = 0;          //root
             ksbxsfr = kroot;
          elseif %scan(',': arrTree(csrrow): csrcol) > csrcol;
             ksbxsfr = %subst(arrTree(csrrow): csrcol:
                             %scan(',': arrTree(csrrow): csrcol) - csrcol);
          elseif %scan(' ': arrTree(csrrow): csrcol) > csrcol;
             ksbxsfr = %subst(arrTree(csrrow): csrcol:
                             %scan(' ': arrTree(csrrow): csrcol) - csrcol);
          else;
             ksbxsfr = %subst(arrTree(csrrow): csrcol: 10);
          endif;

          exsr AddSbx;

          if rrnb = 0;
             exsr EmptyBox;
          else;
             ksbxsz = rrnb;
          endif;
          kmsg = 'Press F1 to start, F12 to cancel.';
          return *on;
       endsr;

       begsr OnRowCol;
          if %scan(',': arrTree(rk): ck) > ck;
             ksbxsfr = %subst(arrTree(rk): ck:
                              %scan(',': arrTree(rk): ck) - ck);
          endif;

          exsr AddSbx;
       endsr;

       begsr AddSbx;
          if rrnb = 1 and arrSchIn(1) = *blank;
             *in37 = *on;
             write ksbxc;
             *in37 = *off;
             rrnb = 0;
          endif;

          if %lookup(ksbxsfr: arrSchIn) = 0;
             if ksbxsfr = kroot;
                ksbxpfm = kroott;
                ksbxslb = krootl;
             else;
                ksbxpfm = GetObjType(ksbxslb: ksbxsfr: csr§: csc§ + 10);     //t
             endif;

             if ksbxpfm = '*PGM' or ksbxpfm = '*SRVPGM';
                ksbxpfm = SelModule(csr§: csc§ + 10:
                                    ksbxpfm: ksbxsfr + ksbxslb:
                                    ksbxslb: ksbxspf);     //pfm=..(x:y:otype:o+

                if ksbxpfm <> *blank;
                   MappingSrc(ksbxslb);

                   rrnb = rrnb + 1;
                   arrSchIn(rrnb) = ksbxsfr;
                   write ksbx;
                   ksbxcs = rrnb;
                endif;
             endif;
          endif;
       endsr;

      /end-free
     P WrkSch          e

     P SearchFor       b
     d SearchFor       pi
     d  string                             like(ksbxfor) value options(*nopass)
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
             kmsg = 'Collect search result error.';
             return;
          endif;

          GetInp(csr§: csc§: 'Save?');
          if kinput = 'YES' and
             xExeCmd('CPYF FROMFILE(QTEMP/' + %trim(psds.prc_name) + ') +
                           TOFILE(*PRINT)') <> *blank;
             kmsg = 'Save collected search result error.';
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
             kmsg = 'Collect search result error.';
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
