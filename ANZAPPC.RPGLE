     H nomain
     fSrcpf     if   f  112        disk    usropn
     fPgmref    if   f  179        disk    usropn
     fAnzapp01  uf a e           k disk    usropn
      *
     d/include anzapps,xcommonds
     d/include anzapps,xsrvproto
     D SetupXref       pr
     d  apps                         10    value

     d IsSysLib        pr              n
     d  lib                          10    value

     d Rsrcpf          ds
     d  srcdta                13    112
     d Rpgmref         ds
     d  F0plib                 1     10
     d  F0pgm                 11     20
     d  F0obj                 89     98
     d  F0olib               100    110
     d  F0fusg               125    126s 0
     d  F0objt               155    155
     d                       175    179

     P SetupXref       b                   export
     d SetupXref       pi
     d  apps                         10     value

     d objLib          s             10

     c                   callp     xExeCmd('CHGJOB LOG(0 40 *MSG)')
      /free
       if xExeCmd('DSPPGMREF PGM(ANZAPPR) OUTPUT(*OUTFILE) +
                             OUTFILE(QTEMP/PGMREF)') <> *blank or
          xExeCmd('CHGPF FILE(QTEMP/PGMREF) SIZE(*NOMAX)') <> *blank;
          return;
       endif;
      /end-free
     c                   if        xExeCmd('OVRDBF FILE(SRCPF) TOFILE(AN-
     c                             ZAPPS) MBR(' + %trim(apps) + ')') <> *blank
     c                   return
     c                   endif

     c                   open      Srcpf

     c                   open      Anzapp01
     c     apps          setll     Anzapp01
     c     apps          reade     Anzapp01
     c                   dow       not %eof
     c                   delete    R00
     c     apps          reade     Anzapp01
     c                   enddo

     c                   eval      F0apps = apps

     c                   dou       %eof(Srcpf)
     c                   read      Srcpf         Rsrcpf
     c                   if        %eof
     c                   leave
     c                   endif

     c                   eval      objLib = srcdta
     c                   if        xExeCmd('DSPPGMREF PGM(' + %trim(objLib) + '-
     c                             /*ALL) OUTPUT(*OUTFILE) OBJTYPE(*ALL) OUTFIL-
     c                             E(QTEMP/PGMREF)') <> *blank
     c                   iter
     c                   endif

     c                   open      Pgmref

     c                   dou       %eof
     c                   read      Pgmref        Rpgmref
     c                   if        not %eof and not IsSysLib(F0olib)
     c                   write(e)  R00
     c                   endif
     c                   enddo

     c                   close     Pgmref

     c                   enddo

     c                   close     Srcpf
     c                   close     Anzapp01
     c                   callp     xExeCmd('DLTOVR FILE(SRCPF)')
     c                   callp     xExeCmd('RGZPFM FILE(ANZAPP00)')

     c                   return
     P SetupXref       e

     P IsSysLib        b
     d IsSysLib        pi              n
     d  lib                          10    value

     d last_syslib     s             10    static inz
     d jobi_ptr        s               *   static inz
     d jobi            ds                  likeds(dsJobi0700) based(jobi_ptr)
     d alib_ptr        s               *   inz
     d alib            s                   like(lib) based(alib_ptr)
     d lb§             s              4b 0
      /free

       if last_syslib <> *blank and lib = last_syslib;
          return *on;
       endif;

       if jobi_ptr = *null;
          jobi_ptr = %alloc(%size(dsJobi0700));
          if xRtvJobInf(jobi_ptr: %size(dsJobi0700): JOBI0700) <> *blank;
             return *off;
          endif;
       endif;

       alib_ptr = %addr(jobi.strLibls);
       for lb§ = 1 to jobi.nbrSysLibl;
           if lib = alib;
              last_syslib = alib;
              return *on;
           endif;
           alib_ptr = alib_ptr + 11;
       endfor;

       return *off;

      /end-free
     P IsSysLib        e
