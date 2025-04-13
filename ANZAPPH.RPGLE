     H nomain
     fHelpf     o    f   80        disk    usropn extfile('QTEMP/ANZAPPH')
     d/include anzapps,xcommonds
     d/include anzapps,xsrvproto
     d hlptxt          s             80    dim(100) ctdata
     d hlp             ds                  qualified
     d  txt                          80
     d DspHelp         pr

     P DspHelp         b                   export
     d DspHelp         pi
     d §§              s              9b 0
      /free

       xExeCmd('CRTPF FILE(QTEMP/ANZAPPH) RCDLEN(80)');
       open(e) Helpf;
       for §§ = 1 to 100;
           hlp.txt = hlptxt(§§);
           write Helpf hlp;
       endfor;
       close Helpf;
       xExeCmd('DSPPFM FILE(QTEMP/ANZAPPH)');

       return;
      /end-free
     P DspHelp         e
** hlptxt
Analyze Application Systems - Help
