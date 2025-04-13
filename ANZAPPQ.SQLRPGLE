     h nomain

     fAnzappq   o  a f   92        disk    usropn

     d Rsrcpf          ds                  qualified
     d  srcseq                        6  2
     d  srcdat                        6  0
     d  srcdta                       80

     d/include anzapps,xcommonds
     d/include anzapps,xsrvproto
     d Xref            pr
     d  pLst                           *   value
     d  pLst1                          *   value
     d  what                         10    value
     d ModExtXref      pr
     d  pModLst                        *   value
     d  pLibLst                        *   value

     P Xref            b                   export
     d Xref            pi
     d  pLst                           *   value
     d  pLst1                          *   value
     d  what                         10    value
      /free
       if what = 'ModExtXref';
          callp ModExtXref(pLst: pLst1);
       endif;
       return;
      /end-free
     P Xref            e

     P ModExtXref      b
     d ModExtXref      pi
     d  pModLst                        *   value
     d  pLibLst                        *   value

     d mod             s             10    based(pMod)
     d modl            s             10    based(pModl)
     d pMod            s               *
     d pModl           s               *
     d nEnt            s              9b 0
     d szEnt           s              9b 0
     d epoLst          ds                  likeds(dsMODL0100) based(lstPtr)
     d lstPtr          s               *
     d epoType         s              9
     d epoName         s             16
     d epoMod          s             10
      /free
       if xExeCmd('CHKOBJ OBJ(QTEMP/MODEXTXREF) OBJTYPE(*FILE)') = 'CPF9801';
          exsr CrtWF;
       endif;

       pMod = pModLst;
       pModl = pLibLst;

       dow mod <> *blank;
           epoMod = mod;
           lstPtr = xLstModEpo(nEnt: szEnt: MODL0100: mod + modl);
           if lstPtr <> *null;
              for nEnt = nEnt downto 1;
                  epoName = %subst(epoLst.epoName: 1:
                                   epoLst.lenExpDefSmbN);
                  if epoLst.expDefSmbType = x'00';
                     epoType = 'Procedure';
                  else;
                     epoType = 'Data';
                  endif;
                  exsr InsWF;
                  lstPtr = lstPtr + epoLst.szOfEntry;
              endfor;
           endif;
           pMod = pMod + 10;
           pModl = pModl + 10;
       enddo;

       exsr OpenCur;
       if sqlStt <> '00000';
          return;
       endif;

       if xExeCmd('CHKOBJ OBJ(QTEMP/ANZAPPQ) OBJTYPE(*FILE)') = 'CPF9801' and
          xExeCmd('CRTSRCPF FILE(QTEMP/ANZAPPQ) RCDLEN(92) MBR(ANZAPPQ)') <>
          *blank;
          return;
       endif;

       open AnzAppq;
       dou sqlStt = '02000';
           exsr FetchCur;
           if sqlStt = '02000';
              leave;
           endif;
           clear Rsrcpf;
           Rsrcpf.srcdta = epoName + ' ' + epoType + ' ' + epoMod;
           write Anzappq Rsrcpf;
       enddo;
       close AnzAppq;

       exsr CloseCur;
       callp xExeCmd('STRSEU SRCFILE(QTEMP/ANZAPPQ) SRCMBR(ANZAPPQ) OPTION(5)');
       callp xExeCmd('CLRPFM FILE(QTEMP/ANZAPPQ)');
       callp xExeCmd('CLRPFM FILE(QTEMP/MODEXTXREF)');

       return;
      /end-free
     csr   CrtWF         begsr
     c/exec sql create table qtemp/modextxref (
     c+     epoName char(16),
     c+     epoType char(9),
     c+     epoMod char(10))
     c/end-exec
     csr                 endsr
     csr   InsWF         begsr
     c/exec sql insert into qtemp/modextxref values (
     c+     :epoName, :epoType, :epoMod)
     c/end-exec
     csr                 endsr
     csr   OpenCur       begsr
     c/exec sql declare cur cursor for
     c+     select * from qtemp/modextxref
     c+            order by epoName
     c/end-exec
     c/exec sql open cur
     c/end-exec
     csr                 endsr
     csr   FetchCur      begsr
     c/exec sql fetch cur into
     c+     :epoName, :epoType, :epoMod
     c/end-exec
     csr                 endsr
     csr   CloseCur      begsr
     c/exec sql close cur
     c/end-exec
     csr                 endsr
     P ModExtXref      e
