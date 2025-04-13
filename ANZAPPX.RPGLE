     H debug  nomain
     fSrcpf     if   f  112        disk    usropn
     fAnzapp20  if   e           k disk    usropn

     d/include anzapps,xcommonds
     d/include anzapps,xsrvproto
     D GetSrc4Lo       pr            10
     d  pgm_srcpf                    20
     d  pgm_attr                     10
     D ChgLibl         pr             1  0
     d  apps                         10    value options(*nopass)
     d MappingSrc      pr
     d  mapLibTo                     10

     d Rsrcpf          ds
     d  srcdta                13    112

     P ChgLibl         b                   export
     d ChgLibl         pi             1  0
     d  apps                         10    value options(*nopass)

     d applibl         s           2750

      /free
       if %parms = 0;
          if xChgLibl() <> *blank;
             return -1;
          endif;
       else;
          exsr SetLib;
       endif;
       return 0;

       begsr SetLib;
          if xExeCmd('OVRDBF FILE(SRCPF) TOFILE(ANZAPPS) MBR(' +
             %trim(apps) + ')') <> *blank;
             return -1;
          endif;

          open Srcpf;
          applibl = *blank;

          dou  %eof;
             read Srcpf Rsrcpf;
             if not %eof;
                applibl = %trim(applibl) + ' ' + %subst(srcdta: 1: 10);
             endif;
          enddo;

          close Srcpf;

          if xExeCmd('DLTOVR FILE(SRCPF)') <> *blank;
             return -1;
          endif;

          if xChgLibl(applibl) <> *blank;
             return -1;
          endif;
       endsr;
      /end-free
     P ChgLibl         e

     P GetSrc4Lo       b                   export
     d GetSrc4Lo       pi            10
     d  pgm_srcpf                    20
     d  pgm_attr                     10

     d pgmInf          ds                  likeds(dsPgmi0100)
     d modLst          ds                  likeds(dsPgml0100) based(lstPtr)
     d lstPtr          s               *
     d nbrEntry        s              9b 0
     d szEntry         s              9b 0

      /free
       if xRtvPgmInf(%addr(pgmInf): %size(pgmInf): PGMI0100: pgm_srcpf)
          <> *blank;
          return *blank;
       endif;

       MappingSrc(pgmInf.srcpfl);
       if pgmInf.typeOfPgm = ' ';           //OPM
          pgm_srcpf = pgmInf.srcpf + pgmInf.srcpfl;
          pgm_attr = pgmInf.attr;
          return pgmInf.srcpfm;
       endif;

       lstPtr = xLstPgmMod(nbrEntry: szEntry: PGML0100:
                           pgmInf.pgm + pgmInf.lib);
       if lstPtr = *null or modLst.mod <> pgmInf.pgm;
          return *blank;
       endif;

       MappingSrc(modLst.srcpfl);

       pgm_srcpf = modLst.srcpf + modLst.srcpfl;
       pgm_attr = modLst.attr;
       return modlst.srcpfm;
      /end-free
     P GetSrc4Lo       e

     P MappingSrc      b                   export
     d MappingSrc      pi
     d  mapLibTo                     10

     d mapLibs         s             10    dim(99) static inz(*hival) ascend
     d toLibs          s             10    dim(99) static inz
     d l@              s              4b 0
      /free

       if mapLibs(1) = *hival;
          open Anzapp20;
          for l@ = 1 to 99;
              read Anzapp20;
              if %eof;
                 leave;
              endif;
              mapLibs(l@) = f2map;
              toLibs(l@) = f2to;
          endfor;
          close Anzapp20;
       endif;

       l@ = %lookup(mapLibTo: mapLibs);
       if l@ > 0;
          mapLibTo = toLibs(l@);
       endif;

       return;

      /end-free
     P MappingSrc      e
