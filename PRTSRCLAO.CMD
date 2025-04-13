             CMD        PROMPT('PRINT SOURCE LAYOUT')

             PARM       KWD(PGM) TYPE(QUAL1) MIN(1) +
                          PROMPT('Program')
             PARM       KWD(SRCLIB) TYPE(*NAME) LEN(10) +
                          PROMPT('Source Library')

 QUAL1:      QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL((*LIBL))
