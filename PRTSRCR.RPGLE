     h dftactgrp(*no) actgrp(*new) bnddir('PRTSRCR')
      *
     d/include anzapps,xcommonds
     d/include anzapps,xsrvproto

     D RtvClpStr       pr
     d  pgm_name                     10
     D RtvPgmStr       pr
     d  pgm_name                     10
     d  pgm_attr                     10

     D GetSrc4Lo       pr            10
     d  pgm_srcpf                    20
     d  pgm_attr                     10
     d  apps                         10    value options(*nopass)

     d pgmName         s             10
     d pgmAttr         s             10
     d qualSrcpf       s             20
     d srcpfMbr        s             10
     d srcpfName       s             10
     d srcpfLib        s             10

     d PRTSRCR         pr
     d  pQualPgm                     20    const
     d  pSrcLib                      10    const options(*nopass)

     d PRTSRCR         pi
     d  pQualPgm                     20    const
     d  pSrcLib                      10    const options(*nopass)

      /free
       qualSrcpf = pQualPgm;
       pgmName = %subst(pQualPgm: 1: 10);

       srcpfMbr = GetSrc4Lo(qualSrcpf: pgmAttr);

       if srcpfMbr = *blank;
          callp xSndPgmMsg('Finding program source error or multi-module +
                          program.');
          return;
       endif;

       srcpfName = %subst(qualSrcpf: 1: 10);
       srcpfLib = %subst(qualSrcpf: 11);
       if %parms = 2 and pSrcLib <> *blank;
          srcpfLib = pSrcLib;
       endif;

       xSndPgmMsg('SRCPF: ' + %trim(srcpfLib) + '/' + %trim(srcpfName) + '.') ;

       if xExeCmd('OVRPRTF FILE(QPRINT) USRDTA('+ %trim(pgmName) + ')')
          <> *blank;
          return;
       endif;

       if xExeCmd('OVRDBF FILE(' + %trim(pgmName) + ') '
                 + 'TOFILE(' + %trim(srcpfLib) + '/'
                 + %trim(srcpfName) + ') MBR('
                 + %trim(srcpfMbr) + ') OVRSCOPE(*JOB)') <> *blank;
          return;
       endif;

       select;
          when pgmAttr = 'CLP' or pgmAttr = 'CLLE';
               callp RtvClpStr(pgmName);
          when pgmAttr = 'RPG' or pgmAttr = 'RPGLE';
               callp RtvPgmStr(pgmName: pgmAttr);
          other;
               callp xSndPgmMsg('Program language '
                             + %trim(pgmAttr) + ' not supported.');
       endsl;

       callp xExeCmd('DLTOVR FILE(' + %trim(pgmName) + ') ' + 'LVL(*JOB)');
       callp xExeCmd('DLTOVR FILE(QPRINT)');

       if %parms = 1;
          callp xExeCmd('WRKSPLF SELECT(*CURRENT *ALL *ALL '
                     + %trim(pgmName) + ')');
       endif;

       return;
      /end-free
