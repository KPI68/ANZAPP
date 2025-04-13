     D xExeCmd         pr             7
     d  cmd                        1024    varying value
     D xChgLibl        pr             7
     d  libl                       2750    value options(*nopass)
     D xSndPgmMsg      pr
     d  msg                          80    varying value

     D xRtvJobInf      pr             7
     d  pRcvVar                        *   value
     d  lRcvVar                       9b 0 value
     d  nFormat                       8    value
     d  qualJobName                  26    value options(*nopass)
     D xRtvSplfA       pr             7
     d  pRcvVar                        *   value
     d  lRcvVar                       9b 0 value
     d  nFormat                       8    value
     d  nSplf                        10    value
     d  qualJob                      26    value options(*nopass)
     d  nbrSplf                       9b 0 value options(*nopass)
     D xRtvPgmInf      pr             7
     d  pRcvVar                        *   value
     d  lRcvVar                       9b 0 value
     d  nFormat                       8    value
     d  qualPgm                      20    value
     D xRtvSpgInf      pr             7
     d  pRcvVar                        *   value
     d  lRcvVar                       9b 0 value
     d  nFormat                       8    value
     d  qualSpg                      20    value

     D xLstPfm         pr              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0
     d  nFormat                       8    value
     d  qualSrcpf                    20    value
     d  nMbr                         10    value options(*nopass)
     d  ovPrc                         1    value options(*nopass)
     D xLstDbr         pr              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0
     d  nFormat                       8    value
     d  qualFile                     20    value
     d  nMbr                         10    value options(*nopass)
     d  rcdfmt                       10    value options(*nopass)
     D xLstObj         pr              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0
     d  nFormat                       8    value
     d  qualObj                      20    value
     d  objType                      10    value options(*nopass)
     D xLstPgmMod      pr              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0
     d  nFormat                       8    value
     d  qualPgm                      20    value
     D xLstSpgMod      pr              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0
     d  nFormat                       8    value
     d  qualSpg                      20    value
     D xLstModEpo      pr              *
     d  nbrEntry                      9b 0
     d  szEntry                       9b 0
     d  nFormat                       8    value
     d  qualMod                      20    value
