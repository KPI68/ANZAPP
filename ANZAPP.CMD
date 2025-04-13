             CMD        PROMPT('Analyze Application Systems')

             PARM       KWD(FILEUSAGE) TYPE(*CHAR) LEN(10) +
                          RSTD(*YES) DFT(*CHANGE) VALUES(*CHANGE +
                          *ANY *ADDONLY) MIN(0) PROMPT('File usage')
