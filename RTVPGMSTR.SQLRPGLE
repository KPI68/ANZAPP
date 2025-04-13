     h
      *
     fQPRINT    O    f  135        printer
      *
     d strPosLe        c                   const(26)
     d strPos3         c                   const(28)
     d betweenSize     c                   const(20)
     d*
     d keyTab          s              8    dim(21) ctdata
     d lenTypeTab      s              2    dim(21) alt(keyTab)
     d*
     d pgmName         s             10
     d attr            s             10
     d strPos          s              2  0
     d sqlStmt         s            256
     d aLine           s            135
     d bufSeq          s              6  2 dim(21)
     d bufDta          s             64    dim(21)
     d bufLevel        s              2  0 dim(21)
     d bf§             s              2  0
     d*
     d LowCas          pr            10
     d  letters                      10
     d KeyWord         pr             1
     d  key                          10
     d NextLevel       pr             5  0
     d  level                         2  0 value
     d  key                          10    value
     d  keySeq                        6  2 value
     d  keyDta                       64    value
     d PrtLin          pr
     d  level                         2  0
     d  srcSeq                        6  2
     d  srcDta                       64
      *
     c     *entry        plist
     c                   parm                    pgmName
     c                   parm                    attr
     c
     c                   if        attr = 'RPGLE'
     c                   eval      strPos = strPosLe
     c                   else
     c                   eval      strPos = strPos3
     c                   endif
     c
     c                   eval      sqlStmt =
     c                             'select srcseq, substr(srcdta,1,64) ' +
     c                             'from ' + pgmName + ' ' +
     c                             'where substr(srcdta,7,1) <> ' +
     c                             x'7d' + '*' + x'7d' + ' and ' +
     c                             'substr(srcdta,6,1) in (' +
     c                             x'7d' + 'c' + x'7d' + ', ' +
     c                             x'7d' + 'C' + x'7d' + ') and ' +
     c                             'ucase(substr(srcdta,' + %editc(strPos:'3') +
     c                             ',10)) <> ' + x'7d' + 'ENDSR' + x'7d'
     c/exec sql prepare stmt from :sqlStmt
     c/end-exec
     c/exec sql declare cur cursor for stmt
     c/end-exec
     c/exec sql open cur
     c/end-exec
     c
     c                   if        sqlstt = '00000'
     c                   clear                   bufSeq
     c                   clear                   bufDta
     c                   clear                   bufLevel
     c                   z-add     0             bf§
     c                   callp     NextLevel( 0 :*blank :0 :*blank)
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
     d NextLevel       pi             5  0
     d  level                         2  0 value
     d  key                          10    value
     d  keySeq                        6  2 value
     d  keyDta                       64    value
     d b§              s              2  0
     d keyType         s              1
     d srcKey          s             10
     d srcType         s              1
     d srcSeq          s              6  2
     d srcDta          s             64
     d myLine#         s              5  0 inz(0)
     d curLevel        s              2  0
     d starAvail       s              1    inz(' ')
      *
     c                   if        level > 0
     c                   add       1             bf§
     c                   move      keySeq        bufSeq(bf§)
     c                   move      keyDta        bufDta(bf§)
     c                   move      level         bufLevel(bf§)
     c                   eval      curLevel = level + 1
     c                   else
     c                   eval      curLevel = level
     c                   endif

     c                   dow       sqlstt = '00000'
     c
     c                   dou       srcType <> 'N' or sqlstt > '00000'
     c/exec sql fetch cur into :srcSeq, :srcDta
     c/end-exec
     c                   if        sqlstt = '00000'
     c                   add       1             myLine#
     c                   eval      srcKey = %subst(srcDta:strPos:10)
     c                   eval      srcType = KeyWord(srcKey)
     c                   endif
     c                   enddo
     c
     c                   if        sqlstt > '00000'
     c                   leave
     c                   endif
     c
     c                   select
     c
     c                   when      srcType = '*'
     c                   callp     PrtLin(curLevel :srcSeq :srcDta)
     c                   eval      starAvail = '*'
     c
     c                   when      srcType = '='
     c                   sub       1             curLevel
     c                   if        bf§ > 0
     c                   exsr      AddBuf
     c                   else
     c                   callp     PrtLin(curLevel :srcSeq :srcDta)
     c                   endif
     c                   add       1             curLevel
     c                   eval      key = srcKey
     c
     c                   when      srcType = '-'
     c                   if        starAvail = '*'
     c                   callp     PrtLin(curLevel :srcSeq :srcDta)
     c                   eval      starAvail = ' '
     c                   else
     c*
     c                   sub       1             curLevel
     c                   if        bf§ = 0
     c                   callp     PrtLin(curLevel :srcSeq :srcDta)
     c                   else
     c                   if        myLine# > betweenSize
     c                   exsr      PrtBuf
     c                   callp     PrtLin(curLevel :srcSeq :srcDta)
     c                   else
     c                   exsr      RmvBuf
     c                   endif
     c                   endif
     c                   if        level = 0
     c                   eval      key = *blank
     c                   else
     c                   return    myLine#
     c                   endif
     c*
     c                   endif
     c
     c                   when      srcType = '+'
     c                   if        key = *blank
     c                   exsr      AddBuf
     c                   add       1             curLevel
     c                   eval      key = srcKey
     c                   else
     c                   eval      myLine# = myLine# +
     c                               NextLevel(curLevel :srcKey :srcSeq :srcDta)
     c                   endif
     c
     c                   when      srcType = ' '
     c                   exsr      PrtBuf
     c                   callp     PrtLin(curLevel :srcSeq :srcDta)
     c
     c                   endsl
     c
     c                   enddo
     c                   return    0
      *
     C     ClrBuf        begsr
     c                   clear                   bufSeq
     c                   clear                   bufDta
     c                   clear                   bufLevel
     c                   z-add     0             bf§
     C                   endsr
      *
     C     PrtBuf        begsr
     c                   do        bf§           b§
     c                   callp     PrtLin(bufLevel(b§) :bufSeq(b§) :bufDta(b§))
     c                   enddo
     c                   exsr      ClrBuf
     C                   endsr
      *
     C     AddBuf        begsr
     c                   if        bf§ = 0
     c                   eval      myLine# = 0
     c                   endif
     c                   if        bf§ < 20
     c                   add       1             bf§
     c                   move      srcSeq        bufSeq(bf§)
     c                   move      srcDta        bufDta(bf§)
     c                   move      curLevel      bufLevel(bf§)
     c                   endif
     c                   if        bf§ >= 20
     c                   exsr      PrtBuf
     c                   endif
     C                   endsr
      *
     C     RmvBuf        begsr
     c                   dow       bf§ > 0 and bufLevel(bf§) = curLevel
     c                   z-add     0             bufSeq(bf§)
     c                   move      *blank        bufDta(bf§)
     c                   z-add     0             bufLevel(bf§)
     c                   sub       1             bf§
     c                   enddo
     C                   endsr
     p NextLevel       e
      *
     p KeyWord         b
     d  KeyWord        pi             1
     d   key                         10
     d  k§             s              2  0
     d  keyLen         s              1  0
     d
     c
     c                   do        21            k§
     c                   movel     lenTypeTab(k§)keyLen
     c                   select
     c                   when      keyTab(k§) > LowCas(key)
     c                   return    'N'
     c                   when      keyTab(k§) =
     c                             %subst( LowCas(key) :1 :keyLen )
     c                   eval      key = keyTab(k§)
     c                   return    %subst(lenTypeTab(k§):2:1)
     c                   endsl
     c                   enddo
     c                   return    'N'
     p KeyWord         e
      *
     p PrtLin          b
     d  PrtLin         pi
     d   level                        2  0
     d   srcSeq                       6  2
     d   srcDta                      64
     d  ch§            s              3  0
     c                   eval      aLine = *blank
     c                   eval      %subst(aLine :1 :2) = %editc(level : '3')
     c
     c                   eval      ch§ = level * 3 + 4
     c                   if        ch§ <= 61
     c                   eval      %subst(aLine :ch§ :7) = %editc(srcSeq:'3')
     c                   eval      %subst(aLine :ch§+7 :64) = srcDta
     c                   else
     c                   eval      aLine = '====> Too many levels!'
     c                   endif
     c                   except    $line
     p PrtLin          e
      *
     p LowCas          b
     d  LowCas         pi            10
     d   letters                     10
     d  c§             s              2  0
     d  lowerCase      s             10    inz(*blank)
     d                 ds
     d  ebcdic                 1      2b 0
     d  upper2lower            2      2
     c                   do        10            c§
     c                   select
     c                   when      %subst(letters :c§ :1) = ' '
     c                   leave
     c                   when      %subst(letters :c§ :1) >= 'A'
     c                   z-add     0             ebcdic
     c                   eval      upper2lower = %subst(letters :c§ :1)
     c                   sub       64            ebcdic
     c                   eval      %subst(lowerCase :c§ :1) = upper2lower
     c                   when      %subst(letters :c§ :1) <= 'z'
     c                   eval      %subst(lowerCase :c§ :1) =
     c                              %subst(letters :c§ :1)
     c                   endsl
     c                   enddo
     c                   return    lowerCase
     p LowCas          e
      *
** keyTab
begsr   5
call    4
cas     3*
chain   5
delet   5
do      2+
else    4=
end     3-
exc     3
exfmt   5
exsr    4
for     3+
goto    4
if      2+
other   5=
read    4
selec   5+
tag     3
updat   5
wh      2=
write   5
