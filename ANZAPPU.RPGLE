     H nomain
     fAnzapp01  if   e           k disk    usropn rename(R00 : R01)
     fAnzapp02  if   e           k disk    usropn
     fAnzapp10  if   e           k disk    usropn
      *
     D GetRoot         pr              *
     d  apps                         10    value
     d  fromObj                      10    value
     d  objLib                       10    value
     d  objUsage                     10    value
     D backward        s               n   Import

     d/include anzapps,xcommonds
     d/include anzapps,xsrvproto

     D NextLevel       pr              *
     d  objstr                       10    value
     d  level1                        1  0 value options(*nopass)
     D InsNode         pr              *
     d  objstr                       10    value
     d  usage                         2p 0 value
     D NewNode         pr              *
     d  objstr                       10    value
     d  usage                         2p 0 value
     D ResetHead       pr
     d NextDbf         pr            10
     d  nPf                          10    value options(*nopass)
     d  libPf                        10    value options(*nopass)

     d node_ds         ds
     d  obj                          10
     d  usage                         2p 0
     d  next                           *
     d  lvllnk                         *
     d  up_ref                         *

     d pHead           s               *
     d theRoot         s               *   inz(*null)
     d theApps         s             10    inz(*blank)
     d theObj          s             10    inz(*blank)
     d theObjLib       s             10    inz(*blank)
     d theObjUsage     s             10    inz(*blank)

     c     key_01        klist
     c                   kfld                    theApps
     c                   kfld                    f0pgm
     c     key_02        klist
     c                   kfld                    theApps
     c                   kfld                    f0obj
     c     key_10        klist
     c                   kfld                    theApps
     c                   kfld                    f0pgm

     P GetRoot         b                   export
     d GetRoot         pi              *
     d  apps                         10    value
     d  fromObj                      10    value
     d  objLib                       10    value
     d  objUsage                     10    value
      /free
       if apps = theApps and fromObj = theObj and
          objLib = theObjLib and objUsage = theObjUsage;
          return theRoot;
       endif;

       callp ResetHead();

       theApps = apps;
       theObj = fromObj;
       theObjLib = objLib;
       theObjUsage = objUsage;

       dou not %error;
           if backward;
              open(e) Anzapp01;
           else;
           open(e) Anzapp02;
           endif;
       enddo;
       open Anzapp10;

       theRoot = NextLevel(fromObj: 0);
       return theRoot;
      /end-free
     P GetRoot         e

     P NextLevel       b
     d NextLevel       pi              *
     d  objstr                       10    value
     d  level                         1  0 value options(*nopass)

     d pNode           s               *
     d node            ds                  likeds(node_ds) based(pNode)

     d lvlPtr          s               *   inz(*null)
     d lvlLast         s               *   inz(*null)
     d lvlRoot         s               *   inz(*null)

     d arrDbf          s            500    varying inz('')
     d arrPgm          s           5000    varying inz('')
     d f§              s              3  0 inz(0)
     d p§              s              5  0
     d ast§            s              2  0
     d dbr1stLvl       s               n

      /free
       dbr1stLvl = (%parms > 1 and level = 0 and
                   (theObjUsage = '*CHANGE' or theObjUsage = '*ANY' or
                    theObjUsage = '*ADDONLY')) and
                   NextDbf(objstr: theObjLib) = *blank;
       dbr1stLvl = dbr1stLvl and not backward;

       if dbr1stLvl = *off;
          if backward;
             f0pgm = objstr;
             setll key_01 Anzapp01;
          else;
          f0obj = objstr;
          setll key_02 Anzapp02;
          endif;
       endif;

       if backward;
          exsr LevelExpandB;
       else;
       exsr LevelExpand;
       endif;

       lvlPtr = lvlRoot;

       dow lvlPtr <> *null;
           pNode = lvlPtr;

           if node.up_ref = *null;
              if dbr1stLvl = *on;
                 node.up_ref = NextLevel(node.obj: 1);
              elseif not backward or node.usage = 0;
                 node.up_ref = NextLevel(node.obj);
              endif;
           endif;

           lvlPtr = node.lvllnk;
       enddo;

       if %parms > 1 and level = 0;
          if backward;
             close Anzapp01;
          else;
          close Anzapp02;
          endif;
          close Anzapp10;
       endif;

       return lvlRoot;

       begsr LevelExpand;
          dou 1 = 2;
             if dbr1stLvl = *on;
                if f0pgm = objStr;
                   leave;
                endif;

                f0pgm = NextDbf();
                f0fusg = 0;
                if f0pgm = *loval;
                   f0pgm = objStr;
                endif;

             else;
                reade key_02 Anzapp02;
                if %eof;
                   leave;
                endif;

                select;
                   when %parms = 1;
                      if f0objt <> 'P' and f0objt <> ' ' and
                         f0objt <> 'J' and f0objt <> 'G' and
                         f0objt <> '*';
                         iter;
                      endif;
                   when theObjUsage = '*CHANGE'  and
                        (f0fusg <= 1 or f0fusg = 8);
                      iter;
                   when theObjUsage = '*ADDONLY' and
                        f0fusg <> 2  and f0fusg <> 3  and
                        f0fusg <> 6  and f0fusg <> 7  and
                        f0fusg <> 10 and f0fusg <> 11 and
                        f0fusg <> 14 and f0fusg <> 15;
                      iter;
                   when theObjUsage = '*ANY'     and f0objt <> 'F' or
                        theObjUsage = '*PGM'     and f0objt <> 'P' or
                        theObjUsage = '*SRVPGM'  and f0objt <> ' ' or
                        theObjUsage = '*DTAARA'  and f0objt <> 'D' or
                        theObjUsage = '*HUBBCH'  and f0objt <> 'J' and
                                                     f0objt <> 'G' and
                                                     f0objt <> '*';
                      iter;
                endsl;

                setll key_10 Anzapp10;    // key_10: f0apps + f0pgm
                if %equal;
                   iter;
                endif;

                readp Anzapp10;
                if not %eof;
                   ast§ = %scan('*': f1obj);
                   if ast§ > 1 and
                      %subst(f1obj: 1: ast§ - 1) = %subst(f0pgm: 1: ast§ - 1)
                      and %subst(f0pgm: ast§) <> *blank;
                      iter;
                   endif;
                endif;
             endif;

             pNode = InsNode(f0pgm: f0fusg);
             if pNode = *null;
                return *null;
             endif;

             if lvlLast = *null;
                lvlRoot = pNode;
                lvlPtr = pNode;
             else;
                lvlPtr = pNode;
                pNode = lvlLast;
                node.lvllnk = lvlPtr;
            endif;

            lvlLast = lvlPtr;
          enddo;
       endsr;

       begsr LevelExpandB;
          dou 1 = 2;
             reade key_01 Anzapp01;
             if %eof;
                leave;
             endif;

             //The level 0 F is prevented in main program
             if f0obj = *blank or
                f0objt = 'F' and theObjUsage = '*CHANGE'  and
                (f0fusg <= 1 or f0fusg = 8) or
                f0objt = 'F' and theObjUsage = '*ADDONLY' and
                f0fusg <> 2  and f0fusg <> 3  and
                f0fusg <> 6  and f0fusg <> 7  and
                f0fusg <> 10 and f0fusg <> 11 and
                f0fusg <> 14 and f0fusg <> 15 or
                theObjUsage = '*DTAARA' or
                theObjUsage = '*HUBBCH' and f0objt <> 'J' and
                                            f0objt <> 'G' and
                                            f0objt <> '*';
                iter;
             endif;

             pNode = InsNode(f0obj: f0fusg);
             if pNode = *null;
                return *null;
             endif;

             if lvlLast = *null;
                lvlRoot = pNode;
                lvlPtr = pNode;
             else;
                lvlPtr = pNode;
                pNode = lvlLast;
                node.lvllnk = lvlPtr;
            endif;

            lvlLast = lvlPtr;
          enddo;
       endsr;
      /end-free
     P NextLevel       e

     P InsNode         b
     d InsNode         pi              *
     d  objstr                       10    value
     d  usage                         2p 0 value

     d pNode           s               *
     d node            ds                  likeds(node_ds) based(pNode)

     d nodePtr         s               *
     d nodeLast        s               *   inz(*null)
      /free
       nodePtr = pHead;

       dow 1 = 1;
          pNode = nodePtr;

          select;
             when pNode = *null or objstr < node.obj or
                  objstr = node.obj and usage < node.usage;
                pNode = NewNode(objstr: usage);
                if pNode = *null;
                   return *null;
                endif;

                if nodeLast = *null;
                   node.next = pHead;
                   pHead = pNode;
                   return pNode;
                endif;

                if nodeLast <> *null;
                   node.next = nodePtr;
                   nodePtr = pNode;
                   pNode = nodeLast;
                   node.next = nodePtr;
                   return nodePtr;
                endif;

             when objstr = node.obj and usage = node.usage;
                pNode = NewNode('ReferTo': usage);
                if pNode = *null;
                   return *null;
                endif;

                node.up_ref = nodePtr;
                return pNode;

             when objstr > node.obj or
                  objstr = node.obj and usage > node.usage;
                nodeLast = nodePtr;
                nodePtr = node.next;
          endsl;
       enddo;

       return *null;
      /end-free
     P InsNode         e

     P NewNode         b
     d NewNode         pi              *
     d  objstr                       10    value
     d  usage                         2p 0 value

     d pNode           s               *
     d node            ds                  likeds(node_ds) based(pNode)
      /free
       monitor;
          pNode = %alloc(%size(node));
          on-error 00425 : 00426;
             return *null;
       endmon;

       clear node;
       node.obj = objstr;
       node.usage = usage;

       return pNode;
      /end-free
     P NewNode         e

     P ResetHead       b
     d ResetHead       pi

     d pNode           s               *
     d node            ds                  likeds(node_ds) based(pNode)
     d nodePtr         s               *

      /free
       nodePtr = pHead;

       dow nodePtr <> *null;
          pNode = nodePtr;
          nodePtr = node.next;
          clear node;
          dealloc(n) pNode;
       enddo;

       pHead = *null;

       return;
      /end-free
     P ResetHead       e

     P NextDbf         b
     d NextDbf         pi            10
     d  nPf                          10    value options(*nopass)
     d  libPf                        10    value options(*nopass)

     d pLst            s               *   static inz(*null)
     d list            ds                  likeds(dsDbrl0100) based(pLst)
     d nbrEnt          s              9b 0 static
     d szEnt           s              9b 0 static
     d rtnDbf          s             10

      /free
       if %parms = 2;
          pLst = xLstDbr(nbrEnt: szEnt: DBRL0100: nPf + libPf);

          if pLst = *null or nbrEnt = 0 or
             nbrEnt = 1 and list.dependent = '*NONE';
             nbrEnt = 0;
             return *loval;                                   // no dependent
          endif;
          return *blank;                                      // some dependents

       else;
          if nbrEnt = 0 or pLst = *null;                      // no more depende
             return *loval;
          endif;

          rtnDbf = list.dependent;

          nbrEnt = nbrEnt - 1;
          pLst = pLst + szEnt;

          return rtnDbf;                                      // next dependent
       endif;
      /end-free
     P NextDbf         e
