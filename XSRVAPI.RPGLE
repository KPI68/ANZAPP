     h nomain

     d/copy anzapps,xsrvproto
     D qCmdExc         pr                  extpgm('QCMDEXC')
     d  cmd                        1024
     d  cmdl                         15  5
     D qUsrJobI        pr                  extpgm('QUSRJOBI')
     d  rcvVar                             likeds(dummy_ds)
     d  lenVar                        9b 0
     d  nFormat                       8
     d  qualJobN                     26
     d  intJobId                     16
     d  errRtn                             likeds(err_rtn_ds)
     d qUsrSplA        pr                  extpgm('QUSRSPLA')
     d  rcvVar                             likeds(dummy_ds)
     d  lenVar                        9b 0
     d  nFormat                       8
     d  qualJob                      26
     d  intJobId                     16
     d  intSplfId                    16
     d  nSplf                        10
     d  nbrSplf                       9b 0
     d  errRtn                             likeds(err_rtn_ds)
     D qClRPgmI        pr                  extpgm('QCLRPGMI')
     d  rcvVar                             likeds(dummy_ds)
     d  lenVar                        9b 0
     d  nFormat                       8
     d  qualPgm                      20
     d  errRtn                             likeds(err_rtn_ds)
     d qBnRSpgm        pr                  extpgm('QBNRSPGM')
     d  rcvVar                             likeds(dummy_ds)
     d  lenVar                        9b 0
     d  nFormat                       8
     d  qualSpg                      20
     d  errRtn                             likeds(err_rtn_ds)

     D qUsLMbr         pr                  extpgm('QUSLMBR')
     d  qualUss                      20
     d  nFormat                       8
     d  qualSrcpf                    20
     d  nMbr                         10
     d  ovPrc                         1
     d  errRtn                             likeds(err_rtn_ds)
     D qDbLDbr         pr                  extpgm('QDBLDBR')
     d  qualUss                      20
     d  nFormat                       8
     d  qualFile                     20
     d  nMbr                         10
     d  rcdfmt                       10
     d  errRtn                             likeds(err_rtn_ds)
     D qUsLObj         pr                  extpgm('QUSLOBJ')
     d  qualUss                      20
     d  nFormat                       8
     d  qualObj                      20
     d  objType                      10
     d  errRtn                             likeds(err_rtn_ds)
     D qBnLPgmI        pr                  extpgm('QBNLPGMI')
     d  qualUss                      20
     d  nFormat                       8
     d  qualPgm                      20
     d  errRtn                             likeds(err_rtn_ds)
     D qBnLSPgm        pr                  extpgm('QBNLSPGM')
     d  qualUss                      20
     d  nFormat                       8
     d  qualSpg                      20
     d  errRtn                             likeds(err_rtn_ds)
     D qBnLModI        pr                  extpgm('QBNLMODI')
     d  qualUss                      20
     d  nFormat                       8
     d  qualMod                      20
     d  errRtn                             likeds(err_rtn_ds)

     D qUsCrtUs        pr                  extpgm('QUSCRTUS')
     d  qualUss                      20
     d  extAttr                      10
     d  inzSize                       9b 0
     d  inzVal                        1
     d  pubAuth                      10
     d  txtDesc                      50
     d  toReplace                    10
     d  errRtn                             likeds(err_rtn_ds)
     D qUsPtrUs        pr                  extpgm('QUSPTRUS')
     d  qualUss                      20
     d  ussPtr                         *
     d  errRtn                             likeds(err_rtn_ds)

     D CrtUss          pr             1  0
     D RtvLst          pr              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0

     d/copy anzapps,xcommonds
     d dummy_ds        ds
     d  dummy                         1
     d qualUss         ds            20
     d  ussName                      10
     d  ussLib                       10    inz('QTEMP')
     d anySpc          ds                  likeds(dummy_ds) based(anySpcPtr)
     d anySpcPtr       s               *

     P xExeCmd         b                   export
     D xExeCmd         pi             7
     d  cmd                        1024    varying value

     d  cmdStr         s           1024
     d  cmdLen         s             15  5
      /free
       cmdStr = cmd;
       cmdLen = %len(cmd);
       monitor;
          callp qCmdexc(cmdStr: cmdLen);
          on-error;
              return psds.CPFMCH_code;
       endmon;
       return *blank;
      /end-free
     P xExeCmd         e

     P xChgLibl        b                   export
     d xChgLibl        pi             7
     d  libl                       2750    value options(*nopass)

     d curLib          s             11    static inz
     d usrLibl         s           2751    static inz
     d rcvVar          ds                  likeds(dsJobi0700)
     d ptrLib          s             10    based(ptr)
     d ptr             s               *
     d rtnId           s              7

      /free
       if %parms = 0;
          if usrLibl = *blank;
             return $GENERR$;
          endif;
          exsr RecLib;
       else;
          if usrLibl <> *blank;
             return $GENERR$;
          endif;
          exsr SetLib;
       endif;

       begsr SetLib;
          rtnId = xRtvJobInf(%addr(rcvVar): %size(rcvVar): JOBI0700);
          if rtnId <> *blank;
             return rtnId;
          endif;

          ptr = %addr(rcvVar.strLibls) + rcvVar.nbrSysLibl * 11 +
                rcvVar.nbrProdLibs * 11;

          if rcvVar.curLibExst = 1;
             curLib = ptrLib;
             ptr = ptr + 11;
          else;
             curLib = '*CRTDFT';
          endif;

          for rcvVar.nbrUsrLibl = rcvVar.nbrUsrLibl downto 1;
             usrLibl = %trim(usrLibl) + ' ' + ptrLib;
             ptr = ptr + 11;
          endfor;

          rtnId = xExeCmd('CHGLIBL LIBL(' + %trim(libl) + ') CURLIB(*CRTDFT)');
          if rtnId <> *blank;
             usrLibl = *blank;
          endif;

          return rtnId;
       endsr;

       begsr RecLib;
          rtnId = xExeCmd('CHGLIBL LIBL(' + %trim(usrLibl) + ') CURLIB(' +
                        %trim(curLib) + ')');
          if rtnId = *blank;
             usrLibl = *blank;
             curLib = *blank;
          endif;
          return rtnId;
       endsr;
      /end-free
     P xChgLibl        e

     P xSndPgmMsg      b                   export
     d xSndPgmMsg      pi
     d  msg                          80    varying value

     d msg_id          s              7    inz(*blank)
     d qual_msgf       s             20    inz(*blank)
     d immed_txt       s             80
     d len_immed_txt   s              9b 0
     d msg_type        s             10    inz('*INFO')
     d callstack_ent   s              7    inz('*CTLBDY')
     d callstack_cntr  s              9b 0 inz(1)
     d msg_key         s              4
     d                 ds
     d err_rtn                       16
     d  bytes_p                       9b 0 inz(16) overlay(err_rtn)
     d len_callst_ent  s              9b 0 inz(7)
     d callst_qualr    s             20    inz('*NONE     *NONE     ')
     d dsp_scr_wait    s              9b 0 inz(0)

     c                   eval      immed_txt = msg
     c                   eval      len_immed_txt = %len(msg)

     c                   call      'QMHSNDPM'
     c                   parm                    msg_id
     c                   parm                    qual_msgf
     c                   parm                    immed_txt
     c                   parm                    len_immed_txt
     c                   parm                    msg_type
     c                   parm                    callstack_ent
     c                   parm                    callstack_cntr
     c                   parm                    msg_key
     c                   parm                    err_rtn
     c                   parm                    len_callst_ent
     c                   parm                    callst_qualr
     c                   parm                    dsp_scr_wait

     c                   return
     P xSndPgmMsg      e

     P xRtvJobInf      b                   export
     d xRtvJobInf      pi             7
     d  pRcvVar                        *   value
     d  lRcvVar                       9b 0 value
     d  nFormat                       8    value
     d  qualJobName                  26    value options(*nopass)

     d err_rtn         ds                  likeds(err_rtn_ds)
     d dft_qualJobN    s             26    inz('*')
     d dft_intJobId    s             16    inz(*blank)
      /free
       anySpcPtr = pRcvVar;
       if %parms = 3;
          callp qUsrJobI(anySpc: lRcvVar: nFormat: dft_qualJobN: dft_intJobId:
                         err_rtn);
       elseif %parms = 4;
          callp qUsrJobI(anySpc: lRcvVar: nFormat: qualJobName: dft_intJobId:
                         err_rtn);
       endif;
       return err_rtn.except_id;
      /end-free
     P xRtvJobInf      e

     P xRtvSplfA       b                   export
     D xRtvSplfA       pi             7
     d  pRcvVar                        *   value
     d  lRcvVar                       9b 0 value
     d  nFormat                       8    value
     d  nSplf                        10    value
     d  qualJob                      26    value options(*nopass)
     d  nbrSplf                       9b 0 value options(*nopass)

     d err_rtn         ds                  likeds(err_rtn_ds)
     d  dft_qualJob    s             26    inz('*')
     d  dft_intJobId   s             16    inz(*blank)
     d  dft_intSplfId  s             16    inz(*blank)
     d  dft_nbrSplf    s              9b 0 inz(-1)
      /free
       anySpcPtr = pRcvVar;
       if %parms = 4;
          callp qUsrSplA(anySpc: lRcvVar: nFormat: dft_qualJob: dft_intJobId:
                         dft_intSplfId: nSplf: dft_nbrSplf: err_rtn);
       elseif %parms = 5;
          callp qUsrSplA(anySpc: lRcvVar: nFormat: qualJob: dft_intJobId:
                         dft_intSplfId: nSplf: dft_nbrSplf: err_rtn);
       elseif %parms = 6;
          callp qUsrSplA(anySpc: lRcvVar: nFormat: qualJob: dft_intJobId:
                         dft_intSplfId: nSplf: nbrSplf: err_rtn);
       endif;
       return err_rtn.except_id;
      /end-free
     P xRtvSplfA       e

     P xRtvPgmInf      b                   export
     d xRtvPgmInf      pi             7
     d  pRcvVar                        *   value
     d  lRcvVar                       9b 0 value
     d  nFormat                       8    value
     d  qualPgm                      20    value

     d err_rtn         ds                  likeds(err_rtn_ds)
      /free
       anySpcPtr = pRcvVar;
       callp qClRPgmI(anySpc: lRcvVar: nFormat: qualPgm: err_rtn);
       return err_rtn.except_id;
      /end-free
     P xRtvPgmInf      e

     P xRtvSpgInf      b                   export
     d xRtvSpgInf      pi             7
     d  pRcvVar                        *   value
     d  lRcvVar                       9b 0 value
     d  nFormat                       8    value
     d  qualSpg                      20    value

     d err_rtn         ds                  likeds(err_rtn_ds)
      /free
       anySpcPtr = pRcvVar;
       callp qBnRSpgm(anySpc: lRcvVar: nFormat: qualSpg: err_rtn);
       return err_rtn.except_id;
      /end-free
     P xRtvSpgInf      e

     P xLstPfm         b                   export
     d xLstPfm         pi              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0
     d  nFormat                       8    value
     d  qualSrcpf                    20    value
     d  nMbr                         10    value options(*nopass)
     d  ovPrc                         1    value options(*nopass)

     d err_rtn         ds                  likeds(err_rtn_ds)
     d dft_nMbr        s             10    inz('*ALL')
     d dft_ovPrc       s              1    inz('0')
      /free
       if CrtUss() < 0;
          return *null;
       endif;

       if %parms = 4;
          callp qUsLMbr(qualUss: nFormat: qualSrcpf: dft_nMbr: dft_ovPrc:
                        err_rtn);
       elseif %parms = 5;
          callp qUsLMbr(qualUss: nFormat: qualSrcpf: nMbr: dft_ovPrc:
                        err_rtn);
       elseif %parms = 6;
          callp qUsLMbr(qualUss: nFormat: qualSrcpf: nMbr: ovPrc:
                        err_rtn);
       endif;

       if err_rtn.bytes_a > 0;
          return *null;
       endif;

       return RtvLst(nbrEntry: szEntry);
      /end-free
     P xLstPfm         e

     P xLstDbr         b                   export
     d xLstDbr         pi              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0
     d  nFormat                       8    value
     d  qualFile                     20    value
     d  nMbr                         10    value options(*nopass)
     d  rcdfmt                       10    value options(*nopass)

     d err_rtn         ds                  likeds(err_rtn_ds)
     d dft_nMbr        s             10    inz('*ALL')
     d dft_rcdfmt      s             10    inz('*ALL')
      /free
       if CrtUss() < 0;
          return *null;
       endif;

       if %parms = 4;
          callp qDbLDbr(qualUss: nFormat: qualFile: dft_nMbr: dft_rcdfmt:
                        err_rtn);
       elseif %parms = 5;
          callp qDbLDbr(qualUss: nFormat: qualFile: nMbr: dft_rcdfmt:
                        err_rtn);
       elseif %parms = 6;
          callp qDbLDbr(qualUss: nFormat: qualFile: nMbr: rcdfmt:
                        err_rtn);
       endif;

       if err_rtn.bytes_a > 0;
          return *null;
       endif;

       return RtvLst(nbrEntry: szEntry);
      /end-free
     P xLstDbr         e

     P xLstObj         b                   export
     d xLstObj         pi              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0
     d  nFormat                       8    value
     d  qualObj                      20    value
     d  objType                      10    value options(*nopass)

     d err_rtn         ds                  likeds(err_rtn_ds)
     d dft_objType     s             10    inz('*ALL')
      /free
       if CrtUss() < 0;
          return *null;
       endif;

       if %parms = 4;
          callp qUsLObj(qualUss: nFormat: qualObj: dft_objType:
                        err_rtn);
       elseif %parms = 5;
          callp qUsLObj(qualUss: nFormat: qualObj: objType:
                        err_rtn);
       endif;

       if err_rtn.bytes_a > 0;
          return *null;
       endif;

       return RtvLst(nbrEntry: szEntry);
      /end-free
     P xLstObj         e

     P xLstPgmMod      b                   export
     d xLstPgmMod      pi              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0
     d  nFormat                       8    value
     d  qualPgm                      20    value

     d err_rtn         ds                  likeds(err_rtn_ds)

      /free
       if CrtUss() < 0;
          return *null;
       endif;

       callp qBnLPgmI(qualUss: nFormat: qualPgm: err_rtn);

       if err_rtn.bytes_a > 0;
          return *null;
       endif;

       return RtvLst(nbrEntry: szEntry);
      /end-free
     P xLstPgmMod      e

     P xLstSpgMod      b                   export
     d xLstSpgMod      pi              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0
     d  nFormat                       8    value
     d  qualSpg                      20    value

     d err_rtn         ds                  likeds(err_rtn_ds)

      /free
       if CrtUss() < 0;
          return *null;
       endif;

       callp qBnLSpgm(qualUss: nFormat: qualSpg: err_rtn);

       if err_rtn.bytes_a > 0;
          return *null;
       endif;

       return RtvLst(nbrEntry: szEntry);
      /end-free
     P xLstSpgMod      e

     P xLstModEpo      b                   export
     d xLstModEpo      pi              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0
     d  nFormat                       8    value
     d  qualMod                      20    value

     d err_rtn         ds                  likeds(err_rtn_ds)

      /free
       if CrtUss() < 0;
          return *null;
       endif;

       callp qBnLModI(qualUss: nFormat: qualMod: err_rtn);

       if err_rtn.bytes_a > 0;
          return *null;
       endif;

       return RtvLst(nbrEntry: szEntry);
      /end-free
     P xLstModEpo      e

     P CrtUss          b
     d CrtUss          pi             1  0

     d err_rtn         ds                  likeds(err_rtn_ds)
     d extAttr         s             10    inz(*blank)
     d inzSize         s              9b 0 inz(1024)
     d inzVal          s              1    inz(x'00')
     d pubAuth         s             10    inz('*EXCLUDE')
     d txtDesc         s             50    inz(*blank)
     d rplYes          s             10    inz('*YES')

      /free
       if ussName = *blank;
          ussName = %subst(psds.job_user: 1: 2) + psds.job_number;
       endif;

       if xExeCmd('CHKOBJ OBJ(QTEMP/' + %trim(ussName) + ') OBJTYPE(*USRSPC)')
          = 'CPF9801';
          callp qUsCrtUs(qualUss:
                         extAttr:
                         inzSize:
                         inzVal:
                         pubAuth:
                         txtDesc:
                         rplYes:
                         err_rtn);
          if err_rtn.bytes_a > 0;
             return -1;
          endif;
       endif;

       return 0;
      /end-free
     P CrtUss          e

     P RtvLst          b
     d RtvLst          pi              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0

     d err_rtn         ds                  likeds(err_rtn_ds)
     d ussHeader       ds                  qualified based(ussPtr)
     d  ofsLst               125    128b 0
     d  nbrLstEnt            133    136b 0
     d  szLstEnt             137    140b 0
     d ussPtr          s               *

      /free
       callp qUsPtrUs(qualUss: ussPtr: err_rtn);

       if err_rtn.bytes_a > 0 or ussHeader.ofsLst <= 0;
          return *null;
       endif;

       nbrEntry = ussHeader.nbrLstEnt;
       szEntry = ussHeader.szLstEnt;

       return ussPtr + ussHeader.ofsLst;
      /end-free
     P RtvLst          e
