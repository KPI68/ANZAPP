     h
      *
     fQPRINT    O    f  151        printer
      *
     d pgmName         s             10
     d strPos          s              2  0
     d sqlStmt         s            256
     d aLine           s            151
     d*
     d NextLevel       pr
     d  level                         2  0 value
     d  bufSeq                        6  2 value
     d  bufDta                      100    value
     d GetKey          pr            10
     d  srcDta                      100          value
     d PrtLin          pr
     d  level                         2  0 value
     d  srcSeq                        6  2
     d  srcDta                      100
      *
     c     *entry        plist
     c                   parm                    pgmName
     c
     c                   eval      sqlStmt =
     c                             'select srcseq, srcdta ' +
     c                             'from ' + pgmName + ' ' +
     c                             'where srcdta <> ' +
     c                             x'7d' + ' ' + x'7d'
     c/exec sql prepare stmt from :sqlStmt
     c/end-exec
     c/exec sql declare cur cursor for stmt
     c/end-exec
     c/exec sql open cur
     c/end-exec
     c
     c                   if        sqlstt = '00000'
     c                   callp     NextLevel( 0 :0 :*blank )
     c                   endif
     c
     c/exec sql close cur
     c/end-exec
     c
     c                   seton                                        lr
      *
     oQPRINT    e            $line       1
     o                       aLine
      *
     p NextLevel       b
     d NextLevel       pi
     d  level                         2  0 value
     d  bufSeq                        6  2 value
     d  bufDta                      100    value
     d srcKey          s             10
     d srcSeq          s              6  2
     d srcDta          s            100
     d curLevel        s              2  0
     d curSeq          s              6  2
     d curDta          s            100
      *
     c                   eval      curLevel = level
     c                   eval      curSeq = bufSeq
     c                   eval      curDta = bufDta

     c                   dow       sqlstt = '00000'
     c
     c                   dou       srcKey <> *blank or sqlstt > '00000'
     c/exec sql fetch cur into :srcSeq, :srcDta
     c/end-exec
     c                   if        sqlstt = '00000'
     c                   if        srcKey = 'comments'
     c                   movel     '/*'          srcDta
     c                   endif
     c                   eval      srcKey = GetKey(srcDta)
     c                   endif
     c                   enddo
     c
     c                   if        sqlstt > '00000'
     c                   leave
     c                   endif
     c
     c                   if        srcSeq = 251
     c                   move      *on           *in11
     c                   endif
     c
     c                   select
     c
     c                   when      srcKey = 'ENDDO'
     c                   sub       1             curLevel
     c                   if        curSeq = 0
     c                   callp     PrtLin(curLevel :srcSeq :srcDta)
     c                   else
     c                   z-add     0             curSeq
     c                   move      *blank        curDta
     c                   endif
     c                   if        level > 0
     c                   return
     c                   endif
     c
     c                   when      srcKey = 'DO'
     c
     c                   if        curSeq > 0
     c                   callp     PrtLin(curLevel-1 :curSeq :curDta)
     c                   z-add     0             curSeq
     c                   move      *blank        curDta
     c                   endif
     c                   callp     NextLevel(curLevel+1 :srcSeq :srcDta)
     c
     c                   when      srcKey = 'CALL'
     c                   if        curSeq > 0
     c                   callp     PrtLin(curLevel-1 :curSeq :curDta)
     c                   z-add     0             curSeq
     c                   move      *blank        curDta
     c                   endif
     c                   callp     PrtLin(curLevel :srcSeq :srcDta)
     c
     c                   endsl
     c
     c                   enddo
     c                   return
     p NextLevel       e
      *
     p GetKey          b
     d  GetKey         pi            10
     d   srcDta                     100          value
     d  k@             s              3  0
     d  codeLine       s              1          dim(100)
     d  key            s             10
     d  beforeKey      s              1
     d  afterKey       s              1
     c                   move      *blank        key
     c                   movea     srcDta        codeLine
     c                   z-add     0             k@
     c                   dow       k@ < 100
     c                   add       1             k@
     c                   select
     c                   when      codeLine(k@) = '/' and k@ < 78
     c                   if        %subst(srcDta:k@:2) = '/*'
     c                   add       2             k@
     c     '*/'          scan      srcDta:k@     k@
     c                   if        %found
     c                   add       1             k@
     c                   else
     c                   eval      key = 'comments'
     c                   leave
     c                   endif
     c                   endif
     c
     c                   when      codeLine(k@) = 'C' and k@ < 78
     c                   eval      key = %subst(srcDta:k@:4)
     c                   eval      beforeKey = *blank
     c                   eval      afterKey = *blank

     c                   if        k@ > 1
     c                   eval      beforeKey = %subst(srcDta:k@-1:1)
     c                   endif
     c                   if        k@ < 77
     c                   eval      afterKey = %subst(srcDta:k@+4:1)
     c                   endif

     c                   if        key <> 'CALL' or
     c                             beforeKey <> ' ' and beforeKey <> '(' or
     c                             afterKey <> ' '
     c                   eval      key = *blank
     c                   else
     c                   leave
     c                   endif
     c
     c                   when      codeLine(k@) = 'E' and k@ < 77
     c                   eval      key = %subst(srcDta:k@:5)
     c                   eval      beforeKey = *blank
     c                   eval      afterKey = *blank

     c                   if        k@ > 1
     c                   eval      beforeKey = %subst(srcDta:k@-1:1)
     c                   endif
     c                   if        k@ < 76
     c                   eval      afterKey = %subst(srcDta:k@+5:1)
     c                   endif

     c                   if        key <> 'ENDDO' or
     c                             beforeKey <> ' ' or
     c                             afterKey <> ' '
     c                   eval      key = *blank
     c                   else
     c                   leave
     c                   endif
     c
     c                   when      codeLine(k@) = 'D' and k@ < 100
     c                   eval      key = %subst(srcDta:k@:2)
     c                   eval      beforeKey = *blank
     c                   eval      afterKey = *blank

     c                   if        k@ > 1
     c                   eval      beforeKey = %subst(srcDta:k@-1:1)
     c                   endif
     c                   if        k@ < 79
     c                   eval      afterKey = %subst(srcDta:k@+2:1)
     c                   endif

     c                   if        key <> 'DO' or
     c                             beforeKey <> ' ' and beforeKey <> '(' or
     c                             afterKey <> ' ' and afterKey <> ')'
     c                   eval      key = *blank
     c                   else
     c                   leave
     c                   endif
     c                   endsl
     c                   enddo
     c                   return    key
     p GetKey          e
      *
     p PrtLin          b
     d  PrtLin         pi
     d   level                        2  0 value
     d   srcSeq                       6  2
     d   srcDta                     100
     d  ch@            s              3  0
     c                   eval      aLine = *blank
     c                   eval      %subst(aLine :1 :2) = %editc(level : '3')
     c
     c                   eval      ch@ = level * 3 + 4
     c                   if        ch@ <= 64
     c                   eval      %subst(aLine :ch@ :7) = %editc(srcSeq:'3')
     c                   eval      %subst(aLine :ch@+7 :100) = srcDta
     c                   else
     c                   eval      aLine = '====> Too many levels!'
     c                   endif
     c                   except    $line
     p PrtLin          e
