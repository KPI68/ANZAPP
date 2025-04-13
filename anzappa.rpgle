     H nomain debug
     fSrcpf     if   f  112        disk    usropn extfile('ANZAPPS')
     f                                            extmbr(apps)
     fSsjgdpp   if   e             disk    usropn prefix(gd_:2)
     f                                     extfile(file_jgdp)
     fSsjbdfp   if   e             disk    usropn prefix(jb_:2)
     f                                     extfile(file_jbdf)
     fSsjbdpp   if   e             disk    usropn prefix(jd_:2)
     f                                     extfile(file_jbdp)
     fSsjgfap   if   e             disk    usropn prefix(fa_:2)
     f                                     extfile(file_jgfa)
     fSsjbfdp   if   e             disk    usropn prefix(fd_:2)
     f                                     extfile(file_jbfd)
     fAnzapp01  uf a e           k disk    usropn
      *
     d/include anzapps,xcommonds
     d/include anzapps,xsrvproto
     d apps            s                   like(f0apps) inz('HUB8_BCH')
     d file_jgdp       s             21
     d file_jbdf       s             21
     d file_jbdp       s             21
     d file_jgfa       s             21
     d file_jbfd       s             21

     D SetupHbch       pr

     P SetupHbch       b                   export
     d SetupHbch       pi

     d Rsrcpf          ds
     d  srcdta                13    112

     c*                  callp     xExeCmd('CHGJOB LOG(0 40 *MSG)')
     c                   open(e)   Srcpf
     c                   if        %error
     c                   return
     c                   endif

     c                   read      Srcpf         Rsrcpf
     c                   if        %eof
     c                   return
     c                   endif
     c                   close     Srcpf
      /free
       file_jgdp = %trim(srcdta) + '/SSJGDPP';
       file_jbdf = %trim(srcdta) + '/SSJBDFP';
       file_jbdp = %trim(srcdta) + '/SSJBDPP';
       file_jgfa = %trim(srcdta) + '/SSJGFAP';
       file_jbfd = %trim(srcdta) + '/SSJBFDP';

       monitor;
          open Ssjgdpp;
          open Ssjbdfp;
          open Ssjbdpp;
          open Ssjgfap;
          open Ssjbfdp;
       on-error;
          return;
       endmon;
      /end-free
     c                   open      Anzapp01
     c     apps          setll     Anzapp01
     c     apps          reade     Anzapp01
     c                   dow       not %eof
     c                   delete    R00
     c     apps          reade     Anzapp01
     c                   enddo

     c                   eval      F0apps = apps
     c                   eval      F0plib = *blank
     c                   eval      F0olib = *blank
     c                   eval      F0fusg = 0

      /free
       dou %eof(Ssjgdpp);
           read Ssjgdpr;
           if %eof;
              leave;
           endif;

           F0pgm = gd_pcjg;
           F0obj = gd_jgid;
           F0objt = 'G';
           write(e) R00;
           exsr ErrorDump;
       enddo;
       close Ssjgdpp;

       dou %eof(Ssjbdfp);
           read Ssjbdfr;
           if %eof;
              leave;
           endif;

           F0pgm = jb_jgid;
           F0obj = jb_jbnm;
           F0objt = 'J';
           write(e) R00;
           exsr ErrorDump;
       enddo;
       close Ssjbdfp;

       dou %eof(Ssjbdpp);
           read Ssjbdpr;
           if %eof;
              leave;
           endif;

           F0pgm = jd_pjnm;
           F0obj = jd_jbnm;
           F0objt = 'J';
           write(e) R00;
           exsr ErrorDump;
       enddo;
       close Ssjbdpp;

       dou %eof(Ssjgfap);
           read Ssjgfar;
           if %eof;
              leave;
           endif;

           F0pgm = fa_jgjb;
           F0obj = fa_flnm;
           F0objt = '*';
           write(e) R00;
           exsr ErrorDump;
       enddo;
       close Ssjgfap;

       dou %eof(Ssjbfdp);
           read Ssjbfdr;
           if %eof;
              leave;
           endif;

           F0pgm = fd_flnm;
           F0obj = fd_jbnm;
           F0objt = 'J';
           write(e) R00;
           exsr ErrorDump;
       enddo;
       close Ssjbfdp;

       close Anzapp01;
       xExeCmd('RGZPFM FILE(ANZAPP00)');
       return;

       begsr ErrorDump;
           if %error;
              dump;
           endif;
       endsr;
      /end-free
     P SetupHbch       e
