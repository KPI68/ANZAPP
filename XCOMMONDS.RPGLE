     d psds           sds                  qualified
     d  prc_name         *proc
     d  pgm_sts          *status
     d  pgm_prv_sts           16     20
     d  rpg_routine      *routine
     d  #parms           *parms
     d  CPFMCH_code           40     46
     d  pgm_lib               81     90
     d  sts09999_CPF          91    170
     d  RNX9001_from         171    174
     d  date_job_str         191    198s 0
     d  job_name             244    253
     d  job_user             254    263
     d  job_number           264    269
     d  date_pgm_str         270    275s 0
     d  date_now             276    281s 0
     d  time_now             282    287s 0
     d  pgm_cont_prc         334    343
     d  mod_cont_prc         344    353
     d  current_user         358    367

     d err_rtn_ds      ds                  qualified
     d  bytes_p                1      4b 0 inz(176)
     d  bytes_a                5      8b 0
     d  except_id              9     15
     d  err_data              17    176

     d dsJobi0700      ds          4096
     d  nbrSysLibl            65     68b 0
     d  nbrProdLibs           69     72b 0
     d  curLibExst            73     76b 0
     d  nbrUsrLibl            77     80b 0
     d  strLibls              81   4096
     d dsSpla0100      ds          1480    qualified
     d  splfNbr               77     80b 0
     d  usrData               91    100
     d  totPages             141    144b 0
     d dsPgmi0100      ds           536    qualified
     d  pgm                    9     18
     d  lib                   19     28
     d  attr                  39     48
     d  srcpf                 62     71
     d  srcpfl                72     81
     d  srcpfm                82     91
     d  typeOfPgm            161    161
     d  actGrp               369    398
     d dsSpgi0100      ds           434    qualified
     d  srvPgm                 9     18
     d  srvPgml               19     28
     d  attr                  39     48
     d  srcpf                 62     71
     d  srcpfl                72     81
     d  srcpfm                82     91

     d dsDbrl0100      ds           320    qualified
     d  dependent             21     30
     d dsMbrl0200      ds                  qualified
     d  name                   1     10
     d  type                  11     20
     d  text                  47     96
     d dsPgml0100      ds           508    qualified
     d  mod                   21     30
     d  modl                  31     40
     d  srcpf                 41     50
     d  srcpfl                51     60
     d  srcpfm                61     70
     d  attr                  71     80
     d dsSpgl0100      ds           508    qualified
     d  mod                   21     30
     d  modl                  31     40
     d  srcpf                 41     50
     d  srcpfl                51     60
     d  srcpfm                61     70
     d
     d dsObjl0100      ds                  qualified
     d  name                   1     10
     d  lib                   11     20
     d  type                  21     30
     d dsModl0100      ds                  qualified
     d  szOfEntry              1      4b 0
     d  expDefSmbType         25     25
     d  lenExpDefSmbN         33     36b 0
     d  epoName               47     61                                         max
     d $GENERR$        c                   'XXX9999'
     d JOBI0700        c                   'JOBI0700'
     d SPLA0100        c                   'SPLA0100'
     d PGMI0100        c                   'PGMI0100'
     d SPGI0100        c                   'SPGI0100'
     d FILD0100        c                   'FILD0100'
     d DBRL0100        c                   'DBRL0100'
     d MBRL0200        c                   'MBRL0200'
     d PGML0100        c                   'PGML0100'
     d SPGL0100        c                   'SPGL0100'
     d OBJL0100        c                   'OBJL0100'
     d MODL0100        c                   'MODL0100'
