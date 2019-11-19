/* -------------------  rexx procedure  -------------------- *
| Name:      ZIGIOSEL                                        |
|                                                            |
| Function:  ISPF Dialog REXX subroutine to select an OMVS   |
|            file and return it to the caller for use.       |
|                                                            |
|            Similar to ISPF 3.17 (UDList) but without all   |
|            the capabilities. But it is easy to traverse    |
|            directories to find the desired file.           |
|                                                            |
| Syntax:    omvsfile = ZIGIOSEL(prime)                      |
|                                                            |
|            omvsfile is the rexx variable that will be      |
|            the result of calling the ZIGIOSEL routine      |
|                                                            |
|                - result will be null if cancelled out      |
|                                                            |
|            prime is optional and if provided is a          |
|            starting point for the selection process        |
|            - if blank/null then start at users home dir    |
|                                                            |
| Commands:  CD to change directories                        |
|            CANCEL to quit and return a null value          |
|            F to find the string in the display             |
|            L to locate the string                          |
|            MKDIR new directory from current location       |
|                                                            |
| Line commands:   B - to browse the selected file           |
|                  L - to list the selected directory        |
|                  I - display info on the file              |
|                  S - to select the file or directory       |
|                      and return it                         |
|                                                            |
| Sample usage:    Must be called from a REXX Exec under     |
|                  ISPF in the foreground:                   |
|                                                            |
|                  omvsfile = ZIGIOSEL()                     |
|                  omvsfile = ZIGIOSEL('/usr/lpp/')          |
|                                                            |
| Notes:     For testing may be called directly and the      |
|            selection will then be displayed using SAY.     |
|                                                            |
| Author:    Lionel B. Dyck                                  |
|                                                            |
| History:  (most recent on top)                             |
|            11/15/19 - Use zigi version                     |
|            11/12/19 - V1.03                                |
|                     - Change ISRZ002 to ISRZ003            |
|            10/22/19 - V1.02                                |
|                     - Prompt for Permissions for MKDIR     |
|            10/18/19 - V1.01                                |
|                     - Added MKDIR                          |
|            06/12/19 - V1.00                                |
|                     - Created from OMVSSEL with permission |
|                       of the author (me)                   |
* ---------------------------------------------------------- */
  parse arg prime

/* ---------------------------------------- *
| Check to see if we are under ISPF or not |
* ---------------------------------------- */
  env = sysvar('sysenv')
  if env = 'FORE' then do
    if sysvar('sysispf') /= 'ACTIVE'
    then do
      say 'Error....'
      say '%ZIGIOSEL may only be used under ISPF.'
      say 'Exiting'
      exit 16
    end
  end
  else do
    say 'Error....'
    say '%ZIGIOSEL may only be used under ISPF under TSO.'
    say 'Exiting'
    exit 16
  end

/* --------------- *
 | Define defaults |
 * --------------- */
  parse value '' with null
  omcsu = 'N'
  parse source x source x
  zerrhm   = 'zigih00'
  zerralrm = 'NO'
  zerrtp   = 'NOTIFY'
  Address ISPExec
  'Control Errors return'

/* --------------------------------- *
 | Get version from zigi shared pool |
 * --------------------------------- */
  'vget (ver)'
  if ver = null then ver = 'zigi'

/* ------------------------------------ *
| Get the users default Home directory |
* ------------------------------------ */
  call syscalls('ON')
  address syscall "getpwnam" userid() "pw."
  home_dir = pw.pw_dir'/'

/* -------------------------------------------- *
| convert \ to / to help out our windows users |
* -------------------------------------------- */
  if prime /= null
  then prime = translate(prime,'61'x,'e0'x)
  else prime = home_dir

/* ----------------------- *
 | Call the key subroutine |
 * ----------------------- */
  ZIGIOSEL = change_odir(prime)

/* --------------------------------- *
 | If cancelled out then return null |
 * --------------------------------- */
  if zcmd = 'CANCEL' then ZIGIOSEL = null

/* --------------- *
| Exit processing |
* --------------- */
Exit:
/* ----------------------------------------------- *
 | Finally return the selected omvs file - or null |
 * ----------------------------------------------- */
  if source = 'FUNCTION' then Exit ZIGIOSEL
  else do
    if ZIGIOSEL = null then ZIGIOSEL = '*none*'
    say 'Selection:' ZIGIOSEL
    exit 0
  end

/* ------------------------------ *
| Change to a new OMVS Directory |
* ------------------------------ */
Change_ODIR: procedure expose zcmd home_dir omcsu ver
  parse arg fromdir
  parse value '' with null selections stack_dir
  if fromdir = '~' then fromdir = home_dir

/* ---------------------------------------------------- *
 | Rebuild the table if L selection or CD command used. |
 * ---------------------------------------------------- */
Restart:
  call do_restart
  tblrc = 0
  do forever
    ocsel = null
    if ztdsels = 0 then tblrc = 0
    if tblrc = 0
    then 'tbdispl' tbl 'panel(zigiotbl)'
    else if tblrc = 4 then 'tbdispl' tbl
    tblrc = rc
    if translate(zcmd) = 'CANCEL' then leave
    if tblrc > 4 then do
      if pos('|',stack_dir) = 0 then leave
      lp = lastpos('|',stack_dir)
      fromdir = strip(substr(stack_dir,lp+1))
      stack_dir = left(stack_dir,lp-1)
      call restart_odir
    end
  if ocsel /= null then ocsel = translate(ocsel)
  zerrsm = null
  Select
    When translate(word(zcmd,1)) = 'MKDIR' then do
       newdir = fromdir'/'word(zcmd,2)
       zs1 = 'Enter the file permissions for the new'
       zs2 = 'directory (e.g. 755):'
       call pfshow 'off'           /* make sure pfshow is off */
       do forever
       'Addpop row(4) column(12)'
       answer = 755
       'Display Panel(zigipopq)'
       'Rempop'
       bad = 0
       if answer = 755 then leave
       else select
            when datatype(answer) /= 'NUM' then bad = 1
            when length(answer) > 3 then bad = 1
            when answer /= 755 then do ia = 1 to 3
               if left(answer,1) > 7 then bad = 1
               if substr(answer,2,1) > 7 then bad = 1
               if right(answer,1) > 7 then bad = 1
               end
            otherwise bad = 0
            end
            if bad = 0 then leave
            zerrsm = 'Error'
            zerrlm = 'Invalid permissions - suggest using 755'
            'setmsg msg(isrz003)'
            end
       call pfshow 'reset'         /* reset pfshow */
       cmd = 'mkdir' newdir
       rc = bpxwunix(cmd,,stdout.,stderr.)
       cmd = 'chmod' answer newdir
       rc = bpxwunix(cmd,,stdout.,stderr.)
       zerrsm = null
       zerrlm = 'Permissions set to:' answer
       'setmsg msg(isrz003)'
       call restart_odir
       end
    When translate(word(zcmd,1)) = 'CD' then do
      savedir = fromdir
      fromdir = word(zcmd,2)
      if left(fromdir,1) = '~' then
         fromdir = strip(home_dir''substr(fromdir,3))
      address syscall 'chdir (fromdir)'
      if retval < 0 then do
        zerrsm = 'Invalid Dir'
        zerrlm = fromdir 'is an invalid directory'
        'setmsg msg(isrz003)'
        fromdir = savedir
      end
      else stack_dir = stack_dir '|' savedir
     address syscall 'getcwd fromdir'
     if right(fromdir,1) /= '/' then fromdir = fromdir'/'
        if zerrsm = null then
        call restart_odir
      end
      When translate(left(zcmd,1)) = 'F' then do
        fw = translate(word(zcmd,2))
        'tbtop' tbl
        do forever
          'tbskip' tbl
          if rc > 0 then leave
          if pos(fw,translate(ofile)) > 0 then do
            zerrsm = 'Found'
            zerrlm = fw 'found in the list'
            'setmsg msg(isrz003)'
            leave
          end
        end
      end
      When translate(left(zcmd,1)) = 'L' then do
        fw = translate(word(zcmd,2))
        fl = length(fw)
        'tbtop' tbl
        do forever
          'tbskip' tbl
          if rc > 0 then leave
          if translate(left(ofile,fl)) = fw then do
            zerrsm = 'Found'
            zerrlm = fw 'found in the list'
            'setmsg msg(isrz003)'
            leave
          end
        end
      end
      When ocsel = 'B' then do
        if otype = '-' then do
          'control display save'
          call outtrap 'x.'
          Address TSO 'OBrowse' fromdir''ofile
          call outtrap 'off'
          'control display restore'
          if x.0 > 0 then do
            zerrsm = 'Error'
            zerrlm = x.2
            'Setmsg msg(isrz003)'
          end
        end
        else do
          zerrsm = 'Invalid'
          zerrlm = 'This file may not be browsed.'
          'Setmsg msg(isrz003)'
        end
      end
      when ocsel = 'I' then call list_info
      when ocsel = 'L' then call do_dirlist
      When ocsel = 'S' then do
         selections = fromdir''ofile
      end
      Otherwise nop
    end
    if selections /= null then leave
    if zcmd = 'CANCEL' then leave
    ocsel = null
  end

  'tbend' tbl

  if selections = null then zcmd = 'CANCEL'
  return selections

/* ---------------------------------------------- *
 | Build the list of directories/files to display |
 * ---------------------------------------------- */
  Do_Restart:
  do forever
    cmd = 'ls -la' fromdir
    rc = bpxwunix(cmd,,stdout.,stderr.)
    if stdout.0 = 0 then do
      zerrsm = 'Invalid Dir'
      zerrlm = fromdir stderr.1
      Address ISPExec 'setmsg msg(isrz003)'
      zcmd = null
      if cdir_flag = 0 then return fromdir
      else do
        if pos('|',stack_dir) = 0 then leave
        lp = lastpos('|',stack_dir)
        fromdir = strip(substr(stack_dir,lp+1))
        stack_dir = left(stack_dir,lp-1)
      end
    end
    else leave
  end
  cdir_flag = 1

/* ------------------------------------------ *
| List the OMVS directory. Once a valid file |
| is selected then process it.               |
* ------------------------------------------ */
  Address ISPExec
  tbl = 'OC'random(999)

  'TBCreate' tbl 'Names(ocsel ofile odate operm otype) Nowrite'

  do i = 2 to stdout.0
    parse value stdout.i with operm x1 oid ogrp ,
      osize omon ody oyr ofile
    otype = left(operm,1)
    opermv = 0
    offset = 100
    do ip = 2 to 10
      op = substr(operm,ip,1)
      select
        when op = 'r' then opermv = opermv + (4*offset)
        when op = 'w' then opermv = opermv + (2*offset)
        when op = 'x' then opermv = opermv + (1*offset)
        otherwise nop
      end
      if ip = 4 then offset = offset / 10
      if ip = 7 then offset = offset / 10
    end
    odate = omon left(ody+100,2) oyr
    operm = opermv
    'tbadd' tbl
  end

  'tbtop' tbl
  return

/* ---------------------------- *
 | Process into a sub directory |
 * ---------------------------- */
do_dirlist:
  ocsel = null
  if ofile = '..' then do
    stack_dir = stack_dir '|' fromdir
    fromdir = left(fromdir,length(fromdir)-1)
    lp = lastpos('/',fromdir)
    fromdir = left(fromdir,lp)
    call restart_odir
    return
  end
  else do
    stack_dir = stack_dir '|' fromdir
    fromdir = fromdir''ofile'/'
  end
  call restart_odir
  return

/* ------------------------------ *
| List the info on the OMVS File |
* ------------------------------ */
List_Info:
  cmd = 'ls -la' fromdir''ofile
  drop stdout. stderr.
  rc = bpxwunix(cmd,,stdout.,stderr.)
/* allocate a temp file to browse the results */
  Address TSO
  cmd_dd = "C"random()
  "ALLOCATE FILE("cmd_dd") REUSE UNIT(vio) SPACE(1 1)" ,
    "CYL DSORG(PS) RECFM(V B) LRECL(120)"
  "EXECIO * DISKW" cmd_dd "(STEM stdout. FINIS)"
  Address ISPExec
  "LMINIT DATAID(DATAID) DDNAME("cmd_dd")"
  'control display save'
  "BROWSE DATAID("dataid")"
  'control display restore'
  "LMFREE DATAID("dataid")"
  Address TSO ,
    "FREE FILE("cmd_dd")"
  Address ISPExec
  return

/* --------------------------------------------- *
| Restart the OMVS Directory at a new directory |
* --------------------------------------------- */
Restart_Odir:
  'tbend' tbl
  call restart
  return

  /* ------------------------------------------------------ *
  | The pfshow routine will:                               |
  | 1. check to see the passed option                      |
  | 2. if Off then it will save the current pfshow setting |
  |    - save the current setting                          |
  |    - turn off pfshow                                   |
  | 3. if the option is Reset then it will                 |
  |    - test if pfshow was on and turn it back on         |
  * ------------------------------------------------------ */
pfshow:
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
