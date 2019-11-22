  /*%NOcomment ----------  rexx procedure  -------------------- *
  | Name:      zigistat                                        |
  |                                                            |
  | Function:  Collect or Compare the ISPF Stats for all       |
  |            members in a PDS                                |
  |                                                            |
  | Syntax:    x=zigistat(dsname filepath option)              |
  |                                                            |
  |            dsname is the z/OS dataset name to work with    |
  |                                                            |
  |            filepath is the OMVS file where the stats are   |
  |            stored and consists of:                         |
  |                localdir/repodir/.zigi/filename             |
  |                filename is the OMVS file that represents   |
  |                the z/OS PDS dataset name                   |
  |                                                            |
  | Options:   C - compare stats                               |
  |            S - save stats                                  |
  |            U - update stats to those saved                 |
  |                used when creating/refreshing datasets      |
  | Usage                                                      |
  |   Notes: Subroutine of zigi                                |
  |          Returns string of members changed                 |
  |                                                            |
  | Dependencies:                                              |
  |          ISPF services                                     |
  |                                                            |
  | Return:                                                    |
  |          0 - stats saved or stats applied                  |
  |          8 - no dsname provided                            |
  |         12 - no filepath provided                          |
  |         16 - no option provided                            |
  |         20 - stats file in /.zigi missing                  |
  |     string - string of members with different stats        |
  |                                                            |
  | Author:    Lionel B. Dyck                                  |
  |                                                            |
  | History:  (most recent on top)                             |
  |            11/22/19 LBD - If a member has no stats - add   |
  |            11/18/19 LBD - Many fixes and add Debug         |
  |            11/15/19 LBD - Creation                         |
  |                                                            |
  * ---------------------------------------------------------- */
zigistat:
  /* ---------------------- *
  | Get the passed options |
  * ---------------------- */
  parse arg dsn filepath opt

  /* --------------- *
  | Define defaults |
  * --------------- */
  parse value '' with null string m. rx
  zdd = 'ZS'time('s')

  /* --------------------------------- *
  | Check for parms and return if not |
  * --------------------------------- */
  parse arg dsn filepath opt
  if dsn      = null then return 8
  if filepath = null then return 12
  if opt      = null then return 16
  opt         = translate(opt)   /* make upper case */

  /* ---------------------------------------- *
  | Check for ZIGIDEBG DD for debug purposes |
  * ---------------------------------------- */
  x = listdsi('ZIGIDEBG' 'FILE')
  if x > 0 then if sysreason = 3
  then zigidebg = 1
  else zigidebg = 0

  x = debug('start of zigistat with option:' opt)

  /* --------------------------------------- *
  | If option C or U then read in the stats |
  | - check if stats member exists rc=16    |
  | - read into stem stats.                 |
  * --------------------------------------- */
  if pos(opt,'C U') > 0 then do
    x = debug('Checking stats file' filepath)
    x = check_stats_file(filepath)
    rc = x
    x = debug('Checking stats file complete')
    if rc > 0 then return x
    address tso
    x = debug('Reading the ISPF stats file')
    drop stats.
    cmd = 'cat' filepath
    x = bpxwunix(cmd,,stats.,se.)
    do i = 1 to stats.0
      stats.i = translate(stats.i,' ','0D'x)
    end
    x = debug('Reading complete')
  end

  /* ------------------ *
  * Define ISPF Dataid *
  * ------------------ */
  Address ISPEXEC
  "LMINIT DATAID(STATUS) DATASET("dsn")"
  "LMOPEN DATAID("STATUS") OPTION(INPUT)"

  /* ------------ *
  * Set defaults *
  * ------------ */
  x = debug('Collecting stats for all members for:' dsn)
  parse value null with member mem. ,
    ZLCDATE ZLMDATE ZLVERS ZLMOD ZLMTIME ZLCNORC,
    ZLINORC ZLMNORC ZLUSER ,
    zlcnorce zlinorce zlmnorce
  mem.0  = 0

  /* ----------------------- *
  * Now process all members *
  * ----------------------- */
  do forever
    "LMMLIST Dataid("status") OPTION(LIST) MEMBER(MEMBER)" ,
      "STATS(YES)"
    /* --------------------------------- *
    * If RC 4 or more leave the do loop *
    * --------------------------------- */
    if rc > 3 then leave
   /* -------------------------------- *
    | Check if no stats then add them. |
    * -------------------------------- */
    if zlcdate = null then do
       'LMMSTATS DATAID('status') Member('member') user('sysvar(sysuid)')'
       "LMMFind DATAID("status") Member("member") STATS(YES)"
       end
    /* ------------------------------ *
    * Add each member info to a stem *
    * ------------------------------ */
    c = mem.0 + 1
    mem.c = strip(member ,
      ZLCDATE  ZLMDATE  ZLVERS ZLMOD ZLMTIME ZLCNORC ,
      ZLINORC ZLMNORC ZLUSER ,
      zlcnorce zlinorce zlmnorce)
    mem.0 = c
  end

  /* ------------------------- *
  * Close and Free the Dataid *
  * ------------------------- */
  "LMClose Dataid("status")"
  "LMFree  Dataid("status")"
  x = debug('Stat collection complete.')

  /* ----------------------------------------------- *
  | Process the data based on the provided options: |
  |                                                 |
  |    C - compare stats                            |
  |    S - save stats                               |
  |    U - update stats to those saved              |
  |        used when creating/refreshing datasets   |
  * ----------------------------------------------- */
  Select
    /* ----------------------------------------------------- *
    | Save all stats for all members in the active dataset. |
    | - data will be saved to /.zigi/filename               |
    * ----------------------------------------------------- */
    When opt = 'S' then do
      x = debug('Saving stats begins to:' filepath)
      x = bpxwunix('rm' filepath,,so.,se.)
      call write_stats
      x = debug('Saving stats completed.')
      return 0
    end
    /* ---------------------------------------------------------- *
    | Update ISPF Stats:                                         |
    |  - all members in the $zigi$ stats member will have their  |
    |    ispf stats updated to reflect the saved stats           |
    |  - new members will not be updated as we don't know about  |
    |   them                                                     |
    |  - members with no stats will have stats added if they are |
    |    in the saved stats member                               |
    * ---------------------------------------------------------- */
    When opt = 'U' then do
      x = debug('Performing ISPF Stats file update for:' dsn)
      "LMINIT DATAID(zstats) DATASET("dsn")"
      "LMOPEN DATAID("zstats") OPTION(INPUT)"
      do i = 1 to stats.0
        parse value stats.i with member ZLCDATE ZLMDATE ZLVERS ZLMOD ,
          ZLMTIME ZLCNORC ZLINORC ZLMNORC ZLUSER ZLCNORCE ,
          ZLINORCE ZLMNORCE .
        if zlcdate = null then ,
          'LMMSTATS DATAID('zstats') Member('member') user('sysvar(sysuid)')'
        else ,
          'LMMSTATS DATAID('zstats') MEMBER('member') VERSION('zlvers')' ,
          'MODLEVEL('zlmod') CREATED('zlcdate') MODDATE('zlmdate')' ,
          'MODTIME('zlmtime') INITSIZE('zlinorc')' ,
          'MODRECS('zlmnorc') USER('zluser')'
      end
      "LMClose Dataid("zstats")"
      x = debug('ISPF Stats file update complete.')
    end
    /* ----------------------------------------------------------- *
    | Compare ISPF stats.                                         |
    |                                                             |
    | Comparison will be from the active datasets ISPF stats with |
    | the saved stats found in ISPF stats file in /.zigi          |
    |                                                             |
    | If a member is in the active but not in the saved list then |
    | it will be added to the returned string.                    |
    |                                                             |
    | If a members saved stats do not match the active stats then |
    | it will be added to the returned string.                    |
    * ----------------------------------------------------------- */
    When opt = 'C' then do
      x = debug('ISPF Stats comparison starting.')
      /* 1st setup the saved stem for easy comparison */
      do i = 1 to stats.0
        parse value stats.i with savedmem data
        m.savedmem = strip(data)
      end
      /* now compare active to saved */
      do i = 1 to mem.0
        parse value mem.i with actmem data
        if m.actmem = null then string = string actmem
        else if data /= m.actmem then string = string actmem
      end
      x = debug('ISPF Stats comparison complete.')
      return string
    end
    Otherwise nop  /* should never get here */
  end

  /* -------------------------------------------- *
  | Check to see if the provided filepath exists |
  | rc 0 it does                                 |
  | rc 20 it does not                            |
  * -------------------------------------------- */
Check_Stats_File:
  save_address = address()
  address syscall 'lstat' filepath 'file.'
  if file.0 = 0 then do
    ADDRESS value(save_address)
    return 20
  end
  else return 0

  /* ----------------------------------------------------- *
  | Get the users current OMVS enviornment for use in the |
  | bpxwunix commands.                                    |
  * ----------------------------------------------------- */
GETENV:
  cmd  = docmdx('env')
  rc = bpxwunix(cmd,,so.,se.)
  envc = 0
  do ci = 1 to so.0
    if left(so.ci,3) = 'GIT' then call add_env so.ci
    if left(so.ci,4) = 'HOME' then call add_env so.ci
    if left(so.ci,4) = 'PATH' then call add_env so.ci
    if left(so.ci,4) = 'MANP' then call add_env so.ci
    if left(so.ci,4) = 'LIBP' then call add_env so.ci
    if left(so.ci,3) = 'PWD' then call add_env so.ci
  end
  call add_env '_BPX_SHAREAS=YES'
  call add_env '_BPX_SPAWN_SCRIPT=YES'
  env.0 = envc
  drop so. se.
  return

  /* -------------------- *
  | Add info to env stem |
  * -------------------- */
add_env:
  parse arg env_val
  envc = envc + 1
  env.envc = env_val
  return

docmd:
  parse arg cmd
  drop so. se.
  cmd = 'bash &&' cmd
  x = bpxwunix(cmd,,so.,se.,env.)
  return x

docmdx:
  /* quircky thing, we need to export HOME as we are
  not running a login shell via bpxwunix */
  parse arg cmd
  drop so. se.
  if rx = null then do
    rx = 'export HOME='home' && . /etc/profile > /dev/null 2>&1 && '
    c = "[[ -f "home"/.profile ]] && echo f"
    x = bpxwunix(c,,o.,e.)
    if o.0 = 1 & o.1 = "f" then do
      rx = rx '. 'home'/.profile > /dev/null 2>&1 && '
    end
  end
  r = rx 'bash && ' cmd
  return r

  /* ----------------------------- *
  | Write out the ISPF Stats file |
  * ----------------------------- */
Write_Stats:
  call syscalls 'ON'
  address syscall
  /* Fill dsn file with the comments */
  'open' filepath O_rdwr+O_creat+O_trunc 660
  if retval = -1 then do
    Address ISPExec
    zs1 = "Something bad when creating" filepath
    zs4 = 'Press F3 to close this popup and exit.'
    parse value '' with zs2 zs3
    call do_popup4
    return
  end
  fd = retval
  do is = 1 to mem.0
    call write_fd mem.is
  end
  'close' fd
  Address ISPExec
  return

  /* ----------------------------------- *
  | Routine to write out a line of data |
  * ----------------------------------- */
Write_FD:
  parse arg string
  string = string || ESC_R || ESC_N
  'write' fd 'string' length(string)
  return

  /* ----------------------------------- *
  | Issue popup - turn off pfshow if on |
  * ----------------------------------- */
Do_Popup4:
  call pfshow 'off'           /* make sure pfshow is off */
  'Control Display Lock'
  'Addpop row(4) column(6)'
  'Display Panel(zigipop4)'
  'Rempop'
  call pfshow 'reset'         /* restore pfshow setting */
  return

  /* -------------------------------- *
  | routine to turn off pfshow if on |
  * -------------------------------- */
pfshow:
  if zpfshow = 'OFF' then return
  arg pfkopt
  if pfkopt = 'RESET' then do
    if pfkeys = 'ON' then
    'select pgm(ispopf) parm(FKA,ON)'
  end
  if pfkopt = 'OFF' then do
    'vget (zpfshow)'
    pfkeys = zpfshow
    if pfkeys /= 'OFF' then
    'select pgm(ispopf) parm(FKA,OFF)'
  end
  return

debug:
  if zigidebg  = 1 then do
    parse arg msg
    msg = Date() Time()' : 'msg
    c = 'echo "'msg'" >> 'home'/zigidebug.txt'
    x = bpxwunix(c,,so.,se.)
    zigidebg_use = 1
  end
  return 0
