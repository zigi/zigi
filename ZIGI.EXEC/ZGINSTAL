/* REXX - must start in column 1 */
  /* --------------------------------------------------------- *
  | Name:      zginstall.rex                                   |
  |                                                            |
  | Function:  ZIGI Package Installation Script                |
  |                                                            |
  | Syntax:    ./zginstall.rex hlq \ option                    |
  |                                                            |
  | Usage:     If hlq is not provided it will be prompted for  |
  |            and used for the z/OS dataset hlq.              |
  |                                                            |
  |            \  - delimeter                                  |
  |                                                            |
  |            x - any non-blank will cause zginstall to       |
  |                copy individual files into the PDS instead  |
  |                of all at once..                            |
  |                                                            |
  | Installation: This script should be installed in the root  |
  |               OMVS directory for the ZIGI managed Git      |
  |               repository.                                  |
  |                                                            |
  |               It is included in this library so that it    |
  |               can be accessed by ZIGI to prime a new, or   |
  |               existing, repository.                        |
  |                                                            |
  | Usage Notes:                                               |
  |            1. Prompt for                                   |
  |               - default HLQ to be used                     |
  |            2. Sequential files that have no lowercase      |
  |               will be processed.                           |
  |            3. Directories that are all uppercase will      |
  |               be assumed to be PDS directories             |
  |            4. Upon completing the upload of all z/OS       |
  |               datasets the hlq.ZGSTAT.EXEC dataset will    |
  |               be generated. It will be pre-configured for  |
  |               the uploaded datasets and when executed will |
  |               apply the ISPF statistics to all partitioned |
  |               dataset members from the ISPF statistics     |
  |               files found in the .zigi directory.          |
  |                                                            |
  | Author:    Lionel B. Dyck                                  |
  |                                                            |
  | History:  (most recent on top)                             |
  |            01/23/23 LBD - Add zgpop4 panel                 |
  |            01/21/23 LBD - Update zigistat subroutine       |
  |            05/16/22 LBD - Remove duplicate routines        |
  |            04/09/22 LBD - Update zigistat to current level |
  |                         - Create zgstat.exec if mixed ds   |
  |            06/03/21 LBD - Change SHAREAS to REQUIRED       |
  |            05/14/21 HBK - Don't parse lowercase folders    |
  |            05/11/21 LBD - Correction for mixed text/binary |
  |            05/06/21 LBD - support allmems > 32k            |
  |            01/06/21 LBD - use .zigi/dsn for z/OS dataset   |
  |                           determination                    |
  |            11/17/20 LBD - Use Dovetail PUTPDS if available |
  |                           as it is faster than cp          |
  |            10/25/20 LBD - Improve usssafe routine          |
  |            10/11/20 LBD - Correct test for existing dsns   |
  |            08/08/20 LBD - Generalize get_binfiles          |
  |            07/29/20 LBD - Add _EDC_ZERO_RECLEN=Y to env.   |
  |            07/24/20 LBD - Adjust Popup Panel Location      |
  |                         - Prompt to Proceed after display  |
  |                           of target datasets               |
  |            07/12/20 LBD - Define OMVS env stem             |
  |            07/04/20 LBD - Use Clear to clear screen        |
  |            06/29/20 LBD - Add generic installer prose      |
  |            06/28/20 LBD - Add text graphics                |
  |                         - Add prose about INPUT state      |
  |            06/27/20 LBD - Use a single cp if the pds is    |
  |                           not mixed (text & binary)        |
  |            06/26/20 LBD - Fixup zgstat.exec dsname quotes  |
  |            06/11/20 LBD - Redesign self contained exec     |
  |            06/10/20 LBD - Tweak for zgstat.exec dsn        |
  |            06/09/20 LBD - Creation from zigickot           |
  | ---------------------------------------------------------- |
  |    zigi - the z/OS ISPF Git Interface                      |
  |    Copyright (C) 2020 - Henri Kuiper and Lionel Dyck       |
  |                                                            |
  |    This program is free software: you can redistribute it  |
  |    and/or modify it under the terms of the GNU General     |
  |    Public License as published by the Free Software        |
  |    Foundation, either version 3 of the License, or (at     |
  |    your option) any later version.                         |
  |                                                            |
  |    This program is distributed in the hope that it will be |
  |    useful, but WITHOUT ANY WARRANTY; without even the      |
  |    implied warranty of MERCHANTABILITY or FITNESS FOR A    |
  |    PARTICULAR PURPOSE.  See the GNU General Public License |
  |    for more details.                                       |
  |                                                            |
  |    You should have received a copy of the GNU General      |
  |    Public License along with this program.  If not, see    |
  |    <https://www.gnu.org/licenses/>.                        |
  * ---------------------------------------------------------- */

  arg options

  parse value options with ckothlq'\'opt

  ckothlq = strip(ckothlq)

  x = bpxwunix('clear')
  say copies('-',73)
  say "                                         .zZ.     Zz "
  say "                    ZZZZZZZZ           ZZZZZZZ "
  say "        ZZZZZZZZZZZZZZZZZZZZZZ   ZZ   ZZZ         zZ "
  say " ZZZZZZZZZZZZZZZZZZZZZZZZZZZZ        ZZZ    .zZZ   ZZ "
  say " ZZZZZZZZZZZZZZZZ      ZZZZZZZ   ZZ   ZZZ  ..zZZZ  Zz "
  say " ZZZZZZZZZZ,         ZZZZZZZZZ   ZZZ  ZzZ      ZZ  ZZ         ZZZZZZZ"
  say " ZZZZ               ZZZZZZZZ     ZZZ   ZZZZZZZZZZZ      ZZZZZZZZZZZ "
  say "                  ZZZZZZZZ       ZZZZ    ZZZZZZ      ZZZZZZZZZg "
  say "                 ZZZZZZZZ        ZZZ            ZZZZZZZZZ "
  say "                ZZZZZZZ              zZZZZZZZZZZZZZZ      Common"
  say "              ZZZZZZZ           ZZZZZZZZZZZZZZ              Installation"
  say "            .ZZZZZZZ      ZZZZZZZZZZZZZZ                      Tool"
  say "           ZZZZZZZZZZZZZZZZZZZZZZ "
  say "           ZZZZZZZZZZZZZZZZZ             zOS ISPF Git Interface "
  say "          ZZZZZZZZZZZZ "
  say "         ZZZZZZZZZZ               The git interface for the rest of us"
  say "        ZZZZZZZZ "
  say "       ZZZZZZZ                         Henri Kuiper & Lionel Dyck "
  say copies('-',73)


  /* --------------------- *
  | Set Default Env and   |
  | Get current directory |
  * --------------------- */
  env.1 = '_BPX_SHAREAS=MUST'
  env.2 = '_BPX_SPAWN_SCRIPT=YES'
  env.3 = '_EDC_ZERO_RECLEN=Y'
  env.0 = 3
  cmd = 'pwd'
  x = bpxwunix(cmd,,so.,se.,env.)
  ckotdir = strip(so.1)

  x = bpxwunix('command -v putpds',,so.,se.)
  if so.0 = 0 then enhanced = 0
  else do
    enhanced = 1
    putpds = so.1
  end

Restart:
  /* ------------------- *
  | Prompt for z/OS HLQ |
  * ------------------- */
  if ckothlq = '' then do
    say 'Enter the z/OS High Level Qualifier to use:'
    pull ckothlq
    if ckothlq = '' then do
      say 'no qualifier entered - exiting for now.'
      exit 8
    end
    ckothlq = translate(strip(ckothlq))
  end

  /* -------------------------------------------------------- *
  | Issue the ls command to get file names and sizes for all |
  | files in the current directory and sub-directories.      |
  * -------------------------------------------------------- */
  cmd = 'ls -laRk' ckotdir
  rc = bpxwunix(cmd,,stdout.,stderr.,env.)

  /* ---------------------------------------------- *
  | Display any error messages and if so then exit |
  * ---------------------------------------------- */
  if stderr.0 > 0 then do
    do i = 1 to stderr.0
      say stderr.i
    end
    exit 8
  end

  /* ------------------------- *
  | Define our work variables |
  * ------------------------- */
  parse value '' with subs files null zgstat_flag
  mgen  = 0
  hit   = 0
  filec = 0

  /* -------------------------------------------------------------- *
  | Inform the user that if there are directories with a lot of    |
  | members to be copied into a PDS tht the OMVS shell may enter   |
  | an INPUT state and to just press F10 - meanwhile the copy (cp) |
  | is proceeding.                                                 |
  * -------------------------------------------------------------- */
  if opt = null then do
    call zmsg ' '
    call zmsg 'If the repository being installed has partitioned datasets'
    call zmsg 'with a large number of members, the copy operation will take'
    call zmsg 'longer than the TN3270 polling expects. This will cause'
    call zmsg 'the OMVS Shell to change from RUNNING to INPUT.'
    call zmsg 'Just press the F10 key to return to a RUNNING state. '
    call zmsg ' '
    call zmsg 'Do not worry, however, as the copy operation is still running'
    call zmsg 'and will report out when it completes (but only if the shell'
    call zmsg 'is in a RUNNING state.'
    call zmsg ' '
  end

  /* ------------------------------------ *
  | Read in ../.zigi/dsn to get dcb info |
  | and for z/OS dsn info                |
  * ------------------------------------ */
  cmd = 'cd' ckotdir '&& ls -la .zigi'
  x = bpxwunix(cmd,,co.,ce.,env.)
  if x > 0 then do
    def_recfm = 'FB'
    def_lrecl = 80
    def_blksize = 32720
    def. = null
  end
  else do
    ckdd = 'ck'time('s')
    x = bpxwunix("cat '"ckotdir"/.zigi/dsn'",,ck.)
    def. = null
    zdsn. = null
    do i = 1 to ck.0
      if left(ck.i,1) = '#' then iterate
      if word(ck.i,1) = '*' then do
        parse value ck.i with . def_dsorg def_recfm def_lrecl def_blksize .
      end
      else do
        dsn = word(ck.i,1)          /* dataset name less hlq */
        def.dsn = subword(ck.i,2)   /* dataset dsorg  */
        zdsn.dsn = word(ck.i,6)     /* file extension */
      end
    end
  end

  Address TSO

  /* ------------------------------- *
  | Get the list of Binary Datasets |
  * ------------------------------- */
  call get_binfiles

  /* ---------------------------------------------------- *
  | Process the results of the ls command to:            |
  | 1. collect number of members per sub-directory       |
  | 2. collect bytes count (in k) for each sub-directory |
  | 3. collect info on sequential files                  |
  * ---------------------------------------------------- */
  if stdout.0 > 0 then
  do i = 1 to stdout.0
    select
      when pos(ckotdir,stdout.i) > 0 then do
        parse value stdout.i with (ckotdir)sub':'
        if left(sub,1) = '/' then sub = substr(sub,2)
        if strip(sub) /= '' then do
          size.sub = 0
          dir.sub = 0
          si = 0
          if left(sub,1) /= '.' then do
            xx = translate(sub,'??????????????????????????',,
                               'abcdefghijklmnopqrstuvwxyz')
            if pos('?',xx) > 0 then iterate /* No lowercase things */
            subs = subs sub
          end
        end
      end
      when word(stdout.i,1) = 'total' then do
        hit = hit + 1
      end
      when hit > 1 & left(stdout.i,1) = '-' then
      if strip(sub) /= '' then do
        size.sub = size.sub + word(stdout.i,5)
        dir.sub = dir.sub + 1
      end
      when hit = 1 & left(stdout.i,1) = '-' then do
        file = word(stdout.i,9)
        if def.file = null then iterate
        if left(file,1) = '.' then iterate
        fx = translate(file,'??????????????????????????', ,
          'abcdefghijklmnopqrstuvwxyz')
        if pos('?',fx) > 0 then iterate
        size.file =  word(stdout.i,5)
        files = files file
      end
      otherwise nop
    end
  end

  call zmsg 'The following Datasets will be Created or Recreated:'
  if words(files) > 0 then
  do fi = 1 to words(files)
    wdsn = "'"ckothlq"."word(files,fi)"'"
    call zmsg wdsn
    if check_file(wdsn) > 0
    then call zmsg '--- Dataset exists and will be recreated.'
  end
  do fi = 1 to words(subs)
    wdsn = "'"ckothlq"."word(subs,fi)"'"
    call zmsg wdsn
    if check_file(wdsn) > 0
    then call zmsg '--- Dataset exists and will be recreated.'
  end
  call zmsg ' '
  say '  '
  say 'Enter Y to Proceed or anything to Retry:'
  pull zgans
  if translate(zgans) /= 'Y' then  do
    ckothlq = null
    signal ReStart
  end

  /* -------------------------------------------- *
  | Process the individual files, if any         |
  | Allocation and Copy                          |
  * -------------------------------------------- */
  do i = 1 to words(files)
    parse value '' with zs1 zs2 zs3 zs4 zs5 zs6 zs7 zs8 zs9
    sub = word(files,i)
    fileg = "'"ckothlq"."sub"'"
    odir = "'"ckotdir"/"sub"'"
    bin = is_binfile(sub)
    if bin = 1 then do
       type = 'Binary'
       zgstat_flag = 1
       end
    else type = 'Text'
    say 'Copying' odir 'to' fileg 'as' type
    filec = filec + 1
    zfile.filec = fileg
    x = check_file(fileg)
    if x > 0 then do
      call outtrap 'x.'
      'delete' fileg
      call outtrap 'off'
    end
    tracks =  (size.sub%50000 + 1) * 2
    call get_dcb
    'alloc ds('fileg') new spa('tracks','tracks') tr dsorg(ps)' ,
      'recfm('recfm') lrecl('lrecl') blksize('blksize')'
    'free ds('fileg')'
    'oget' odir fileg type
  end

  /* -------------------------------------------- *
  | Process the sub-directories and initiate the |
  | Allocation and Copy                          |
  | Ignore subdirectories                        |
  * -------------------------------------------- */
  do isub = 1 to words(subs)
    parse value '' with zs1 zs2 zs3 zs4 zs5 zs6 zs7 zs8 zs9
    sub = word(subs,isub)
    bin = is_binfile(sub)
    if bin = 1 then do
       type = 'Binary'
       zgstat_flag = 1
       end
    else type = 'Text'
    fx = translate(sub,'??????????????????????????', ,
      'abcdefghijklmnopqrstuvwxyz')
    if pos('?',fx) > 0 then iterate
    tracks =  (size.sub%50000 + 1) * 2
    call alloc_copy_pds
  end

  /* ------------------------------------------ *
  | Now update and create the zgstat.exec file |
  * ------------------------------------------ */
  if enhanced = 0 | zgstat_flag = 1 then do
    c = 0
    hit = 0
    last = sourceline()
    do i = 1 to last
      card = sourceline(i)
      if  left(card,8) = '>ZGSTATE' then leave
      if hit = 0 then
      if  left(card,8) = '>ZGSTAT ' then do
        hit = 1
        iterate
      end
      else iterate
      if pos('$$$$$$',card) > 0 then do
        parse value card with var '=' .
        if translate(var) = 'REPODIR' then
        card = "   repodir ='"ckotdir"'"
        if translate(var) = 'HLQ' then
        card = "   hlq ='"ckothlq"'"
      end
      c = c + 1
      zg.c = card
    end
    zg.0 = c

    Address syscall
    path = ckotdir'/lrhg.rex'
    'open' path O_rdwr+O_creat+O_trunc 660
    if retval = -1 then do
      say 'Unable to open the output file for ZGSTAT.EXEC'
      say 'so ISPF statistics will not be able to be recreated.'
      exit 8
    end
    fd = retval
    do i = 1 to zg.0
      rec = zg.i ESC_N
      'write' fd 'rec' length(rec)
    end
    'close' fd
    Address TSO

    zgstat_dsn = "'"ckothlq".ZGSTAT.EXEC'"
    say ' '
    cmd = 'cp -v  lrhg.rex "//'zgstat_dsn '"'
    cmd = cmd '&& rm lrhg.rex'
    x = bpxwunix(cmd,,so.,se.,env.)
    if so.0 > 0 then
    do i = 1 to so.0;say so.i;end
    if se.0 > 0 then
    do i = 1 to se.0;say se.i;end
  end

  /* -------------------- *
  | Done with everything |
  * -------------------- */
  say ' '
  say 'Completed - z/OS datasets created:'
  say ' '
  do i = 1 to filec
    say zfile.i
  end
  if enhanced = 0 | zgstat_flag = 1 then do
    say ' '
    say 'Note that using this installation path does not allow the ISPF'
    say 'statistics to be recreated. Other than the missing ISPF statistics'
    say 'everything has been successfully installed on z/OS.'
    if if enhanced /= 0 then if zgstat_flag = 1 then do
       say ' '
       say 'One, or more, partitioned datasets (PDS) had both text and binary'
       say 'members. This prevented the ISPF statistics from being created'
       say 'for that PDS.'
       end
    say ' '
    say 'To recreate the ISPF statistics execute the following command'
    say 'after returning to TSO/ISPF:'
    say ' '
    say 'TSO EX' zgstat_dsn 'EX'
    say ' '
    say 'After it completes successfully it can be deleted.'
  end

  Exit

zmsg:
  parse arg message
  if strip(message) = null then
  message = copies('-',63)
  say '* 'left(message,63)' *'
  return

  /* ----------------------------------------------------- */
  /* number format code thanks to Doug Nadel               */
  /* ----------------------------------------------------- */
fix_num: procedure
  arg bytes
  str=strip(translate('0,123,456,789,abc,def', ,
    right(bytes,16,','), ,
    '0123456789abcdef'),'L',',')
  bytes = strip(str)
  return bytes

  /* ----------------------------------------------------------------- *
  | Allocate the PDS and perform the copy using cp                    |
  | - if the target PDS exists as a PDS, delete and realloc as a PDSE |
  | - if the target is a PDSE then it will NOT be reallocated         |
  | - The target PDS will be allocated as a PDSE version 2.           |
  | - if maxgen (mgen) is provided then member generations will       |
  |   also be defined at allocation                                   |
  | - Uppercase and remove defined extension for members              |
  * ----------------------------------------------------------------- */
Alloc_Copy_PDS:
  pds = "'"ckothlq"."sub"'"
  odir = "'"ckotdir"/"sub"/'"
  filec = filec + 1
  zfile.filec = pds
  x = check_file(pds)
  if x > 0 then do
    call outtrap 'x.'
    Address TSO ,
      'delete' pds
    call outtrap 'off'
  end
  call get_dcb
  if recfm = 'U' then do
    type = 'Load module'
  end
  say 'Copying' odir 'to' pds
  if mgen > 0 then gens = 'maxgens('mgen')'
  else gens = null
  'Alloc new spa('tracks','tracks') recfm('recfm') lrecl('lrecl')' ,
    'Blksize('blksize') Dsntype(Library,2) dsorg(po) dir(1)' ,
    'dsn('pds')' gens
  'Free ds('pds')'

  /* ---------------------------------------------------- *
  | Read directory to get all member file names and then |
  | adjust according and then do individual cp           |
  * ---------------------------------------------------- */
  target = strip(pds,'B',"'")
  address syscall
  rdir = strip(odir,'B',"'")
  rdir = strip(rdir,'T','/')
  'readdir' rdir 'mems.'
  tcount = mems.0 - 2

  mixed = check_mixed_bintext(sub)

  if mixed = 0 then do
    bin = is_binfile(sub)
    if bin = 1 then binopt = '-B'
    else binopt = null
    if recfm = 'U' then binopt = '-X -I'
    if binopt = null then type = 'Text'
    else if binopt = '-B' then type = 'Binary'
    else if recfm = 'U' then type = 'Load module'
    if type = 'Binary' then
       zgstat_flag = 1
    say 'Copying' tcount 'members as' type
    if enhanced = 0 | recfm = 'U' then do
      zos = usssafe("//'"target"'")
      cmd = 'cp -A -U -v' binopt usssafe(rdir'/*') '"'zos'"'
    end
    else do
      putpds_opts = null
      if pos('-B',binopt) > 0 then putpds_opts = '-b'
      sp = lastpos('/',rdir,length(rdir)-1)
      sfile = substr(rdir,sp+1)
      putpds_opts = putpds_opts '-M st='ckotdir'/.zigi/'sfile
      zos = usssafe("//"target)
      cmd = putpds putpds_opts usssafe(rdir)'/*' zos
    end
    x = docmd(cmd)
    if x > 0 then do
      say ' '
      say 'Copy command:' cmd
      say ' '
      say 'Standard messages:'
      say ' '
      do vs = 1 to so.0;say so.vs;end
      say ' '
      say 'Error messages:'
      say ' '
      do vs = 1 to se.0;say se.vs;end
    end
  end
  else do   /* mixed text and binary in same PDS */
    mcount = 0
    do ii = 1 to mems.0
      if mems.ii = "." | mems.ii = ".." then do
        /* skip the . and .. things */
        iterate
      end
      m = mems.ii    /* ignore the translation */
      if zdsn.sub /= null then
      if right(m,length(zdsn.sub)) = zdsn.sub then do
        parse value m with m'.'.
        m = translate(m)
      end
      src = rdir'/'mems.ii
      bin = is_binfile(sub'/'mems.ii)
      if bin = 1 then binopt = '-B'
      else binopt = null
      if recfm = 'U' then binopt = '-X -I'
      src = usssafe(mems.ii)
      if left(src,1) = '#' then src = '\'src
      zos = usssafe("//'"target"("m")'")
      mcount = mcount + 1
      if binopt = null then type = 'Text'
      else if binopt = '-B' then  type = 'Binary'
      else if recfm = 'U' then type = 'Load module'
      if type = 'Binary' then
         zgstat_flag = 1
      say left('Copying' mcount 'of' tcount,24) 'Member:' m 'as' type
      cmd = 'cd' usssafe(rdir)
      cmd = cmd '&& cp -U -v' binopt src '"'zos'"'
      x = docmd(cmd)
      if x > 0 then do
        say ' '
        say 'Standard messages:'
        say ' '
        do vs = 1 to so.0;say so.vs;end
        say ' '
        say 'Error messages:'
        say ' '
        do vs = 1 to se.0;say se.vs;end
      end
    end
  end
  return

get_dcb:
  if def.sub /= null then do
    parse value def.sub with dsorg recfm lrecl blksize .
    recfm = left(recfm,1) substr(recfm,2,1) substr(recfm,3,1)
  end
  else do
    recfm = left(def_recfm,1) substr(def_recfm,2,1) substr(def_recfm,3,1)
    lrecl = def_lrecl
    blksize = def_blksize
  end
  return

Check_File: Procedure
  arg dsn
  call outtrap 'x.'
  Address TSO 'Listd' dsn
  call outtrap 'off'
  if x.0 > 3 then return 8
  else return 0

  /* ---------------------------------------- *
  | Check if a PDS has mixed binary and text |
  | 0 = not mixed   1 = mixed                |
  * ---------------------------------------- */
Check_Mixed_BinText:
  parse arg checkForBinFile
  cmbtRC = 0
  if datatype(binfiles.0) /= 'NUM' then return 0
  do bi = 1 to binfiles.0
    parse value binfiles.bi with cmbtfile'/'cmbtmbr
    parse value checkForBinFile with checkFile'/'checkmbr
    if cmbtfile = checkFile then
    if cmbtmbr = '*' then cmbtRC = 0
    else return 1
    if binfiles.bi = checkForBinFile then return 1
  end
  return cmbtRC

usssafe:
  parse arg safe_command
  safe_ret = 1
  if pos('\$',safe_command) > 0 then safe_ret = 0
  if pos('\#',safe_command) > 0 then safe_ret = 0
  if safe_ret = 0 then return safe_command
  if pos('$',safe_command)  > 0 then safe_ret = 1
  if pos('#',safe_command)  > 0 then safe_ret = 1
  if safe_ret = 0 then return safe_command
  safe$pos = 1
  do forever
    pos$safe = pos('$',safe_command,safe$pos)
    if pos$safe < 1 then leave
    left$safe = left(safe_command,pos$safe-1)
    right$save = substr(safe_command,pos$safe)
    safe_command = left$safe'\'right$save
    safe$pos = pos$safe + 2
  end
  safe$pos = 1
  do forever
    pos$safe = pos('#',safe_command,safe$pos)
    if pos$safe < 1 then return safe_command
    left$safe = left(safe_command,pos$safe-1)
    right$save = substr(safe_command,pos$safe)
    safe_command = left$safe'\'right$save
    safe$pos = pos$safe + 2
  end
  return safe_command

strreplace: Procedure
  string  = arg(1)
  strfrom = arg(2)
  strto   = arg(3)
  null = ''
  if pos(strfrom,string) = 0 then return string
  newString = null
  do i = 1 to length(string)
    if substr(string,i,1) /= strfrom
    then newstring = newstring''substr(string,i,1)
    else  newstring = newstring''strto
  end
  return newstring

get_binfiles:
  /* ---------------------------------------------------------\
  | Name:      binfiles                                        |
  |                                                            |
  | Function:  Fills the global binfiles. stem with all        |
  |            current repo files that are added as binary.    |
  \---------------------------------------------------------- */
  cmd = 'cd' ckotdir'/ &&'
  cmd = 'cat -W filecodeset=UTF-8,pgmcodeset=IBM-1047' ckotdir'/.gitattributes'
  cmd = cmd ' | grep BINARY'
  cmd = cmd '| cut -d" " -f1'
  x = docmd(cmd)
  if so.0 = 0 then do
    binfiles.0 = 0
    return 0
  end
  do b = 1 to so.0
    binfiles.b = so.b
  end
  binfiles.0 = so.0
  return 0

is_binfile: procedure expose binfiles.
  /* ---------------------------------------------------------\
  | Name:      is_binfile                                      |
  |                                                            |
  | Function:  Checks the global binfiles. stem for the        |
  |            provided dataset or dataset/member              |
  \---------------------------------------------------------- */
  parse arg file
  if datatype(binfiles.0) /= 'NUM' then return 0
  do bi = 1 to binfiles.0
    if right(binfiles.bi,1) = '*' then do
      parse value file with test'/'.
      if left(binfiles.bi,length(binfiles.bi)-2) = test
      then return 1
    end
    if binfiles.bi = file then return 1
  end
  return 0

docmd:
  parse arg cmd
  drop so. se.
  x = bpxwunix(cmd,,so.,se.,env.)
  return x

/*
>ZGSTAT     *** Inline ZGSTAT that will be updated and uploaded */
  /*---------------------  rexx procedure  -------------------- *
  | Name:      ZGSTAT                                          |
  |                                                            |
  | Function:  To work with the ZIGI Generic Installation      |
  |            tool to add the ISPF statistics to the ZIGI     |
  |            managed partitioned datasets after they have    |
  |            been created by the ZGINSTALL.                  |
  |                                                            |
  | Syntax:    ex zgstat ex                                    |
  |                                                            |
  | Dependencies: Uses a modified copy of the ZIGI zigistat    |
  |               exec                                         |
  |                                                            |
  | Author:    Lionel B. Dyck                                  |
  |                                                            |
  | History:  (most recent on top)                             |
  |            06/11/20 LBD - Put inline in zginstall.rex      |
  |            06/10/20 LBD - Usability enhancements           |
  |            06/09/20 LBD - Creation                         |
  |                                                            |
  | ---------------------------------------------------------- |
  |    ZIGI - the z/OS ISPF Git Interface                      |
  |    Copyright (C) 2020 - Henri Kuiper and Lionel Dyck       |
  |                                                            |
  |    This program is free software: you can redistribute it  |
  |    and/or modify it under the terms of the GNU General     |
  |    Public License as published by the Free Software        |
  |    Foundation, either version 3 of the License, or (at     |
  |    your option) any later version.                         |
  |                                                            |
  |    This program is distributed in the hope that it will be |
  |    useful, but WITHOUT ANY WARRANTY; without even the      |
  |    implied warranty of MERCHANTABILITY or FITNESS FOR A    |
  |    PARTICULAR PURPOSE.  See the GNU General Public License |
  |    for more details.                                       |
  |                                                            |
  |    You should have received a copy of the GNU General      |
  |    Public License along with this program.  If not, see    |
  |    <https://www.gnu.org/licenses/>.                        |
  * ---------------------------------------------------------- */

/* ------------------------------------------------ *
 | These variables will be updated by zginstall.rex |
 * ------------------------------------------------ */
  repodir = '$$$$$$'
  hlq     = '$$$$$$'

  Address ISPExec
  load_info = loadispf()

  address syscall ,
    'readdir' repodir 'files.'

  if files.0 = 0 then do
    zedsmsg = 'Error'
    zedlmsg = 'The directory specified is not the correct directory.'
    'setmsg msg(isrz001)'
    exit 8
  end

  do if = 1 to files.0
    file = files.if
    if left(file,1) = '.' then iterate
    /* check for lower case so ignore these */
    fx = translate(file,'??????????????????????????', ,
      'abcdefghijklmnopqrstuvwxyz')
    if pos('?',fx) > 0 then iterate
    dsname = "'"hlq"."file"'"
    x = listdsi(dsname)
    if sysdsorg /= 'PO' then iterate
    msg1 = 'Applying ISPF Statistics to:'
    msg2 = dsname
    call pfshow 'off'           /* make sure pfshow is off */
    'Control Display Lock'
    'Addpop row(8) column(11)'
    'Display Panel(zgpop)'
    'Rempop'
    call pfshow 'reset'         /* restore pfshow setting */
    x = zigistat(dsname repodir'/.zigi/'file 'U')
  end

Done:
  x = dropispf(load_info)
  zedsmsg = 'Completed.'
  zedlmsg = 'ZGSTAT completed ISPF statistics updates.'
  'setmsg msg(isrz001)'
  exit 0

Cancel:
  x = dropispf(load_info)
  Say 'ZGSTAT utility canceled.'
  exit 8

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

  /* Inline ISPF Elements - must remain within a comment
>Start
>Panel zgstat
)Attr
  _ type(input) caps(on) hilite(uscore)
  $ type(input) caps(off) hilite(uscore)
)Body Window(65,7)
+
+Enter the z/OS Dataset HLQ (Prefix):
_hlq                          +
+
+Enter the OMVS Directory for the Repository:
$repodir                                                      +
+
)Init
 &zwinttl = 'ZIGI Statistics Apply Utility'
)Proc
  ver (&hlq,nb,dsname)
  ver (&repodir,nb)
)End
>Panel zgpop
)Attr
 @ type(output) caps(off) intens(low)
)Body Window(46,4)
+
@msg1
@msg2
+
)Init
 &zwinttl = 'ZIGI Statistics Apply Utility'
)Proc
  ver (&hlq,nb,dsname)
  ver (&repodir,nb)
)End
>Panel zgpop4
)Attr
 $ type(output) caps(off)
)Body Window(62,6)
+
  $zs1
  $zs2
  $zs3
  $zs4

)Init
 &zwinttl = 'ZIGI Status Popup'
)Proc
)end
/* -------------------------------------------------------- */
/* ZIGI - the z/OS ISPF Git Interface                       */
/* Copyright (C) 2020 GPL V3 - Henri Kuiper and Lionel Dyck */
/* -------------------------------------------------------- */
>End   */


  /* --------------------  rexx procedure  -------------------- *
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
  |                localdir/repodir/.ZIGI/filename             |
  |                filename is the OMVS file that represents   |
  |                the z/OS PDS dataset name                   |
  |                                                            |
  | Options:   C - compare stats                               |
  |            S - save stats                                  |
  |            U - update stats to those saved                 |
  |                used when creating/refreshing datasets      |
  |                                                            |
  | Vars:      statmems ispf variable for selective update     |
  |                                                            |
  | Usage                                                      |
  |   Notes: Subroutine of ZIGI                                |
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
  |            10/16/22 LBD - Delete amdlist sysprint tmp dsn  |
  |            07/19/22 LBD - Fix chtag mixed error            |
  |            06/19/22 LBD - Fix suffix check compare         |
  |            04/25/22 TPM - Add 2 dropped statements         |
  |                           (LBD - my bad)                   |
  |            03/23/22 TPM - list of repo files not in PDS    |
  |                           merged by LBD                    |
  |            03/07/22 LBD - Update usssafe routine tests     |
  |            03/05/22 LBD - Update usssafe routine for #     |
  |            03/04/22 LBD - Add ISPF Stats if PDS member     |
  |                           does not have them               |
  |            03/03/22 LBD - Correct debugfil variable        |
  |            02/15/22 LBD - Correct if no Dovetail           |
  |            02/07/22 LBD - Fix stats if NOCOZ               |
  |            12/18/21 LBD - Correct dsorg/recfm test         |
  |            10/18/21 LBD - Correctly tag stats file         |
  |            10/08/21 LBD - Check for background             |
  |            08/18/21 LBD - Correct AMBLIST for Link and     |
  |                           Add AMBLIST analysis popups      |
  |            08/16/21 LBD - Align amblist (lmod) file        |
  |                         - Support PDSE lmod libraries      |
  |            08/04/21 LBD - Use encoding to tag stats file   |
  |            08/02/21 LBD - Correct use of dovedir variable  |
  |                         - use AMBLIST for load libraries   |
  |            07/26/21 LBD - Fix allmems missing one member   |
  |            06/03/21 LBD - Change SHAREAS to REQUIRED       |
  |            05/29/21 LBD - Clean up environment setup       |
  |            05/26/21 LBD - Use dovetail getpds for stats    |
  |            05/18/21 LBD - More popups with info and fix    |
  |                           allmems variables setup          |
  |            05/06/21 LBD - Multiple allmems variables       |
  |            10/25/20 LBD - Improve usssafe routine          |
  |            09/27/20 LBD - Compare stats improved           |
  |            08/14/20 LBD - Don't update if readonly repo    |
  |            06/19/20 LBD - Ignore LMOD aliases as the main  |
  |                           lmod will have them included     |
  |            06/16/20 LBD - Use DEFRUID if it exists         |
  |            06/09/20 LBD - Bypass stat update for lmod      |
  |            05/08/20 LBD - Support Load Libraries           |
  |            01/08/20 LBD - Selecitve stat update if statmems|
  |            01/05/20 LBD - Correct special chars in filepath|
  |                           using usssafe routine            |
  |            11/22/19 LBD - If a member has no stats - add   |
  |            11/18/19 LBD - Many fixes and add Debug         |
  |            11/15/19 LBD - Creation                         |
  |                                                            |
  | ---------------------------------------------------------- |
  |    ZIGI - the z/OS ISPF Git Interface                      |
  |    Copyright (C) 2020-2021 - Henri Kuiper and Lionel Dyck  |
  |                                                            |
  |    This program is free software: you can redistribute it  |
  |    and/or modify it under the terms of the GNU General     |
  |    Public License as published by the Free Software        |
  |    Foundation, either version 3 of the License, or (at     |
  |    your option) any later version.                         |
  |                                                            |
  |    This program is distributed in the hope that it will be |
  |    useful, but WITHOUT ANY WARRANTY; without even the      |
  |    implied warranty of MERCHANTABILITY or FITNESS FOR A    |
  |    PARTICULAR PURPOSE.  See the GNU General Public License |
  |    for more details.                                       |
  |                                                            |
  |    You should have received a copy of the GNU General      |
  |    Public License along with this program.  If not, see    |
  |    <https://www.gnu.org/licenses/>.                        |
  * ---------------------------------------------------------- */
zigistat:

  /* --------------- *
  | Define defaults |
  * --------------- */
  parse value '' with null string m. rx allmems codep
  zdd = 'ZS'time('s')

  /* ---------------------------------- *
   | Check for Background of Foreground |
   * ---------------------------------- */
   if sysvar('sysenv') = 'FORE'
      then background = 0
      else background = 1

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

  Address ISPExec
  'vget (debugfil defruid readonly dovedir encoding)'
  parse value encoding with .'-'codep .
  if codep = null then codep = 1047

  call getenv

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
    x = debug('Reading the ISPF stats file')
    drop stats.
    cmd = 'cat' usssafe(filepath)
    x = bpxwunix(cmd,,stats.,se.)
    do i = 1 to stats.0
      stats.i = translate(stats.i,' ','0D'x)
    end
    x = debug('Reading complete')
  end

  /* ------------------ *
  * Define ISPF Dataid *
  * ------------------ */
  Address ISPExec

  /* ---------------------------------- *
  | Get dataset recfm (check for lmod) |
  * ---------------------------------- */
  x = listdsi(dsn)

  /* ------------ *
  * Set defaults *
  * ------------ */
  x = debug('Collecting stats for all members for:' dsn)
  parse value null with member mem. ,
    ZLCDATE ZLMDATE ZLVERS ZLMOD ZLMTIME ZLCNORC,
    ZLINORC ZLMNORC ZLUSER ,
    zlcnorce zlinorce zlmnorce ,
    zlsize zlamod zlrmode zlattr zlalias zlssi
  mem.0  = 0
  if defruid = null
  then newuid = sysvar('sysuid')
  else newuid = defruid

  zs1 = 'Collecting statistics for:'
  zs2 = dsn
  zs3 = null
  zs4 = null
  call do_popup4

  /* ----------------------- *
  * Now process all members *
  * ----------------------- */
  if sysdsorg = 'PO' & sysrecfm = 'U'
  then do
       zs3 = 'Collecting Load Module Information'
       call do_popup4
       Address TSO
       x = get_loadlib(dsn)
       Address ISPExec
       end
  else if sysdsorg = 'PO' then do
    if dovedir = 0 then do
      "LMINIT DATAID(STATUS) DATASET("dsn")"
      "LMOPEN DATAID("STATUS") OPTION(INPUT)"
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
        if sysrecfm /= 'U' then
        if zlcdate = null then
        if readonly = 0 then do
          'LMMSTATS DATAID('status') Member('member') user('newuid')'
          "LMMFind DATAID("status") Member("member") STATS(YES)"
        end
        /* ------------------------------ *
        * Add each member info to a stem *
        * ------------------------------ */
        c = mem.0 + 1
        if sysrecfm /= 'U'
        then mem.c = strip(member ,
          ZLCDATE  ZLMDATE  ZLVERS ZLMOD ZLMTIME ZLCNORC ,
          ZLINORC ZLMNORC ZLUSER ,
          zlcnorce zlinorce zlmnorce)
        else if strip(zlalias) = null then do
          mem.c = strip(member ,
            zlsize zlamod zlrmode zlattr zlalias zlssi)
        end
        else c = c - 1
        mem.0 = c
        if strip(zlalias) = null then
        if opt = 'C' then allmems = allmems member
        if c//100 = 0 then do
          zs3 = 'Processing count:' c
          call do_popup4
        end
      end

      /* ------------------------- *
      * Close and Free the Dataid *
      * ------------------------- */
      "LMClose Dataid("status")"
      "LMFree  Dataid("status")"
    end
    else do
      dovedir = subword(dovedir,2)
      cmd = usssafe(dovedir"getpds -M st=- //"strip(dsn,'B',"'"))
      drop mem. se.
      x = debug('Get ISPF Stats using getpds:' cmd)
      x = bpxwunix(cmd,,mem.,se.,env.)
      do mi = 1 to mem.0
        allmems = allmems word(mem.mi,1)
      end
    end
  end
  x = debug('Stat collection complete.')

  zs1 = 'Collection complete.'
  call do_popup4

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
      x = bpxwunix('rm' usssafe(filepath),,so.,se.)
      call write_stats
      cmd = 'chtag -tc' codep usssafe(filepath)
      x = bpxwunix(cmd,,so.,se.)
      x = debug('Saving stats completed.')
      return 0
    end
    /* ---------------------------------------------------------- *
    | Update ISPF Stats:                                         |
    |  - all members in the ZIGI stats member will have their    |
    |    ispf stats updated to reflect the saved stats           |
    |  - Use statmems ispf var for selective stat updates        |
    |  - new members will not be updated as we don't know about  |
    |   them                                                     |
    |  - members with no stats will have stats added if they are |
    |    in the saved stats member                               |
    * ---------------------------------------------------------- */
    When opt = 'U' then do
      if readonly = 1 then return 0
      if sysrecfm /= 'U' then do
        x = debug('Performing ISPF Stats file update for:' dsn)
        'vget (statmems)'
        if statmems /= null then do
          x = debug('Update Members:' statmems)
        end
        "LMINIT DATAID(zstats) DATASET("dsn")"
        "LMOPEN DATAID("zstats") OPTION(INPUT)"
        do i = 1 to stats.0
          parse value stats.i with member ZLCDATE ZLMDATE ZLVERS ZLMOD ,
            ZLMTIME ZLCNORC ZLINORC ZLMNORC ZLUSER ZLCNORCE ,
            ZLINORCE ZLMNORCE .
          if statmems /= null then
          if wordpos(member,statmems) = 0 then iterate
          if zlcdate = null then ,
            'LMMSTATS DATAID('zstats') Member('member') user('sysvar(sysuid)')'
          else ,
            'LMMSTATS DATAID('zstats') MEMBER('member') VERSION('zlvers')' ,
            'MODLEVEL('zlmod') CREATED('zlcdate') MODDATE('zlmdate')' ,
            'MODTIME('zlmtime') INITSIZE('zlinorc')' ,
            'MODRECS('zlmnorc') USER('zluser')'
        end
        "LMClose Dataid("zstats")"
        "LMFree  Dataid("zstats")"
        x = debug('ISPF Stats file update complete.')
        return 0
      end
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
      zs1 = 'Begin comparing stats'
      call do_popup4
      /* 1st setup the saved stem for easy comparison */
      do i = 1 to stats.0
        parse value stats.i with savedmem cd md . . mt . . . uid .
        m.savedmem = strip(cd md left(mt,5) uid)
      end
      /* now compare active to saved */
      do i = 1 to mem.0
        if i//100 = 0 then do
          zs3 = 'Checked' i 'members of' mem.0
          call do_popup4
        end
        parse value mem.i with actmem cd md . . mt . . . uid .
        data = strip(cd md left(mt,5) uid)
        if m.actmem = null
        then string = string actmem
        else if data /= m.actmem then string = string actmem
        if datatype(uid) /= 'CHAR' then data = null
        if strip(data) = null then call update_member_ispf_stats
      end
      zs3 = 'Completed - building member list.'
      call do_popup4
      allmemsc = 0
      allmems = strip(allmems)

      /* From TPM */
      /* now that allmems has been populated, and before we start cutting */
      /* it up to store ISPF variable versions, identify and store a list */
      /* of the names of any repo directory files not found in the list.  */

      parse var filepath pfx '/.zigi' sfx
      repo_dir = pfx || sfx

      cmd = 'ls -l' repo_dir
      x = bpxwunix(cmd,,ro.,se.,env.)

      repo@nf = ''

      do n = 1 to ro.0
        if words(ro.n) < 3 then iterate n

        repo_mem = word(ro.n,words(ro.n))

        if pos('.',repo_mem) > 0 then do
           p = pos('.',repo_mem)
           repo_mem = translate(left(repo_mem,p-1))
           end

        if wordpos(repo_mem,allmems) = 0 then repo@nf = repo@nf repo_mem
        end

      repo@nfc = 0

      if repo@nf <> '' then do
        if length(repo@nf) < 32000 then do
          repo@nfc = 1
          repo@nf1 = strip(repo@nf)
          'VPUT (REPO@NF1)'
          end
        else do forever
          repo@nfc = repo@nfc + 1
          if length(repo@nf) > 32000 then
            lp = lastpos(' ',repo@nf,length(repo@nf)-32000)
          else lp = 0

          if lp > 0 then do
            interpret 'repo@nf'repo@nfc '=' substr(repo@nf,lp)
            repo@nf = strip(left(repo@nf,lp-1))
            end
          else do
            interpret 'repo@nf'repo@nfc '= strip(repo@nf)'
            repo@nf = null
            end

          'VPUT (REPO@NF'repo@nfc')'
          if strip(repo@nf) = null then leave
          end
        end          /* end if repo@nf <> '' */

      'VPUT (REPO@NFC)'

      if length(allmems) < 32000
      then do
        allmemsc = allmemsc + 1
        interpret 'allmems'allmemsc '= allmems'
        'vput (allmems'allmemsc')'
      end
      else do forever
        allmemsc = allmemsc + 1
        if length(allmems) > 32000
        then lp = lastpos(' ',allmems,length(allmems)-32000)
        else lp = 0
        if lp > 0
        then do
          interpret 'allmems'allmemsc '=' substr(allmems,lp)
          allmems = left(allmems,lp-1)
        end
        else do
          interpret 'allmems'allmemsc '= allmems'
          allmems = null
        end
        'vput (allmems'allmemsc')'
        if strip(allmems) = null then leave
      end
      'vput (allmemsc)'
      x = debug('ISPF Stats comparison complete:' string)
      return string
    end
    Otherwise nop  /* should never get here */
  end

Update_Member_ISPF_Stats:
    "LMINIT DATAID(zstats) DATASET('"sysdsname"')"
    "LMOPEN DATAID("zstats") OPTION(INPUT)"
    parse value mem.actmem with cdt mdt mtm uid
    if uid /= null then
    'LMMSTATS DATAID('zstats') Member('actmem') Created('cdt')',
           'Moddate('mdt') Modtime('mtm') User('uid')'
    else
    'LMMSTATS DATAID('zstats') Member('actmem') User('userid()')'
    "LMClose Dataid("zstats")"
    "LMFree  Dataid("zstats")"
   return

  /* -------------------------------------------- *
  | Check to see if the provided filepath exists |
  | rc 0 it does                                 |
  | rc 20 it does not                            |
  * -------------------------------------------- */
Check_Stats_File:
  address syscall 'lstat' filepath 'file.'
  if file.0 = 0 then do
    ADDRESS ISPExec
    return 20
  end
  else return 0

  /* ----------------------------------------------------- *
  | Get the users current OMVS enviornment for use in the |
  | bpxwunix commands.                                    |
  * ----------------------------------------------------- */
GETENV:
  cmd = 'pwd'
  omvsenv.1 = '_BPX_SHAREAS=MUST'
  omvsenv.0 = 1
  x = bpxwunix(cmd,,so.,se.,omvsenv.)
  home    = strip(so.1)

  x = debug('Starting collection of env variables')

  cmd  = docmdx('env')

  rc = bpxwunix(cmd,,env.,se.,omvsenv.)
  envc = env.0
  call add_env '_BPX_SHAREAS=MUST'
  call add_env '_BPX_SPAWN_SCRIPT=YES'
  call add_env 'EXPORT _EDC_ADD_ERRNO2=1'
  call add_env '_EDC_ZERO_RECLEN=Y'
  env.0 = envc

docmdx:
  /* quircky thing, we need to export HOME as we are
  not running a login shell via bpxwunix */
  parse arg cmd
  drop o. se.
  if gitenv /= null
  then envfile = '.' gitenv ' >/dev/null 2>&1 &&'
  else envfile = null

  /* check for users .profile */
  address syscall 'lstat' "'"home"/.profile'" 'x.'
  if x.0 > 0 then home_profile =  ". "home"/.profile &&"
  else home_profile = null

  rx = 'export HOME='home' && . /etc/profile > /dev/null 2>&1 && ' ,
    home_profile envfile
  r = rx ' ' cmd
  return r

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
  x = bpxwunix(cmd,,so.,se.,env.)
  return x

  /* ----------------------------- *
  | Write out the ISPF Stats file |
  * ----------------------------- */
Write_Stats:
  call syscalls 'ON'
  address syscall
  /* Fill dsn file with the comments */
  /* look like the 'open' command does the escaping for us... */
  fpok = strreplace(filepath,'\$', '$')
  'open' fpok O_rdwr+O_creat+O_trunc 660
  if retval = -1 then do
    Address ISPExec
    zs1 = "Something bad when creating"
    zs2 = filepath
    zs4 = 'Press F3 to close this popup and exit.'
    parse value '' with zs3
    call do_popup4
    'close' fd
    call syscalls 'OFF'
    return
  end
  fd = retval
  do is = 1 to mem.0
    call write_fd mem.is
  end
  'close' fd
  call syscalls 'OFF'
  Address ISPExec
  lp = lastpos('/',filepath)
  chpath = left(filepath,lp)
  chfile = substr(filepath,lp+1)
  x = docmd('cd' chpath '&& chtag -tc' encoding chfile)
  return

  /* ----------------------------------- *
  | Routine to write out a line of data |
  * ----------------------------------- */
Write_FD:
  parse arg string
  string = string || ESC_N
  'write' fd 'string' length(string)
  return

  /* ----------------------------------- *
  | Issue popup - turn off pfshow if on |
  * ----------------------------------- */
Do_Popup4:
  if background = 1 then do
     if strip(zs1) /= null then say zs1
     if strip(zs2) /= null then say zs2
     if strip(zs3) /= null then say zs3
     if strip(zs4) /= null then say zs4
     return
     end
  if address() /= 'ISPEXEC' then do
     poptso = 1
     Address ISPExec
     end
  else poptso = 0
  call pfshow 'off'           /* make sure pfshow is off */
  'Control Display Lock'
  'Addpop row(4) column(6)'
  'Display Panel(zgpop4)'
  'Rempop'
  call pfshow 'reset'         /* restore pfshow setting */
  if poptso = 1 then Address TSO
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
    c = 'echo "'msg'" >>' debugfil
    x = bpxwunix(c,,dso.,dse.)
  end
  return 0

usssafe:
  parse arg safe_command
  safe_ret = 1
  if pos('\$',safe_command) > 0 then safe_ret = 0
  if pos('\#',safe_command) > 0 then safe_ret = 0
  if safe_ret = 0 then return safe_command
  if pos('$',safe_command)  > 0 then safe_ret = 1
  if pos('#',safe_command)  > 0 then safe_ret = 1
  if safe_ret = 0 then return safe_command
  safe$pos = 1
  do forever
    pos$safe = pos('$',safe_command,safe$pos)
    if pos$safe < 1 then leave
    left$safe = left(safe_command,pos$safe-1)
    right$save = substr(safe_command,pos$safe)
    safe_command = left$safe'\'right$save
    safe$pos = pos$safe + 2
  end
  safe$pos = 1
  do forever
    pos$safe = pos('#',safe_command,safe$pos)
    if pos$safe < 1 then return safe_command
    left$safe = left(safe_command,pos$safe-1)
    right$save = substr(safe_command,pos$safe)
    safe_command = left$safe'\'right$save
    safe$pos = pos$safe + 2
  end
  return safe_command

STRREPLACE:
  ORIGINAL = ARG(1)
  OLDTXT = ARG(2)
  NEWTXT = ARG(3)
  /* YOU CAN CHANGE THE BELOW KEY (TMPTXT), WHICH IS USED AS A TEMPORARY
  POINTER TO IDENTIFY THE TEXT TO BE REPLACED */
  TMPTXT = '6A53CD2EW1F'
  NEWSTR = ORIGINAL
  DO WHILE POS(OLDTXT,NEWSTR) > 0
    NEWSTR = SUBSTR(NEWSTR, 1 , POS(OLDTXT,NEWSTR)-1) ||,
      TMPTXT || SUBSTR(NEWSTR, POS(OLDTXT,NEWSTR) + LENGTH(OLDTXT))
  END
  DO WHILE POS(TMPTXT,NEWSTR) > 0
    NEWSTR = SUBSTR(NEWSTR, 1 , POS(TMPTXT,NEWSTR)-1) ||,
      NEWTXT || SUBSTR(NEWSTR, POS(TMPTXT,NEWSTR) + LENGTH(TMPTXT))
  END
  RETURN NEWSTR

Get_LoadLib:
  arg lm_dsname

  drop mem.
  oc = 0

  if sysvar('syspref') /= ''
  then syspds = sysvar("syspref")".z"date("J")
  else syspds = sysvar("sysuid")".z"date("J")

  call outtrap 'x.'
  'free f(sysin sysprint syslib)'
  call outtrap 'off'

  cc.1 = ' LISTIDR OUTPUT=ALL'
  cc.0 = 1
  cal = null

  call outtrap 'x.'
  "delete '"syspds"'"
  call outtrap 'off'

  'Alloc f(syslib) ds('lm_dsname') shr reuse'
  'Alloc f(sysprint) unit(sysallda) spa(900,1500) tr new reuse' ,
    "ds('"syspds"')"
  'Alloc f(sysin) unit(sysallda) spa(1,1) tr recfm(f b) lrecl(80)' ,
    'blksize(80) new reuse'
  'Execio * diskw sysin (finis stem cc.'
  drop cc.

  address Link 'amblist'

  'free f(sysprint)'

  zs3 = 'AMBList completed - Filtering now.'
  call do_popup4

  /* -------------------------------------- *
  | Escape any $ found in the dataset name |
  * -------------------------------------- */
  if pos('$',syspds) > 0 then
  do forever
    if pos('\$',syspds) > 0 | pos('$',syspds) = 0 then leave
    p = pos('$',syspds)
    ld = left(syspds,p-1)
    rd = substr(syspds,p+1)
    syspds = ld'\$'rd
  end

  grep_string = 'MEMBER|PRODUCED'

  /* --------------------------------------------- *
  | Create OMVS supported format for dataset name |
  * --------------------------------------------- */
  dsn = '"//'||"'"syspds"'"||'"'

  /* ----------------- *
  | Drop results stem |
  * ----------------- */
  drop results.

  /* ---------------------------------------------------- *
  | Invoke BPXWUNIX                                      |
  | 1st to cat (copy) the z/OS dataset into the pipe (|) |
  | and 2nd to grep (search) the results for the string  |
  | with the results going into the results. stem        |
  | and errors into the e. stem.                         |
  * ---------------------------------------------------- */
  x = bpxwunix('cat' dsn "| grep -E -i '"grep_string"'",,results.,e.)

  'Free  f(syslib)'
  'Alloc f(sysin) ds(*) reuse'
  'Alloc f(sysprint) ds(*) reuse'

  call outtrap 'x.'
  'delete' "'"syspds"'"
  call outtrap 'off'

  zs3 = 'Analyzing the filtered AMBLIST data.'
  zs4 = results.0 'records to process.'
  call do_popup4

  do lmi = 1 to results.0
    if word(results.lmi,1) = 'MEMBER' then do
      member = left(word(results.lmi,3),8)
    end
    if subword(results.lmi,2,2) = 'PROGRAM OBJECT' then do
       time = word(results.lmi,15)
       parse value word(results.lmi,13) with dmon'/'day'/'year
       day   = date('d',year''dmon''day,'s')
       year = right(year,2)
       cal  = year''right(day+1000,3)
       end
    if word(results.lmi,8) = 'BINDER' & word(results.lmi,19) = 'AT' then do
      day = word(results.lmi,15)
      year = substr(word(results.lmi,18),3,2)
      time = left(word(results.lmi,20),8)
      cal  = year''day
    end
    if word(results.lmi,8) = 'BINDER' & word(results.lmi,19) /= 'AT' then do
      day = word(results.lmi,15)
      year = substr(word(results.lmi,18),3,2)
      time = left(word(results.lmi,20),8)
      cal  = year''day
    end
    if word(results.lmi,7) = 'LINKAGE' & word(results.lmi,10) = 'AT' then do
      day = word(results.lmi,15)
      year = substr(word(results.lmi,18),3,2)
      time = left(word(results.lmi,20),8)
      cal  = year''day
    end
    if cal <> '' then do
      oc = oc + 1
      mem.oc = left(member,8) cal time
      mem.0 = oc
        if opt = 'C' then allmems = allmems member
        if oc//100 = 0 then do
          zs3 = 'Processing count:' oc
          Address ISPExec
          call do_popup4
          Address TSO
        end
      cal = ''
    end
  end

  return 0

  /* --------------------  rexx procedure  -------------------- *
  * Name:      LoadISPF                                        *
  *                                                            *
  * Function:  Load ISPF elements that are inline in the       *
  *            REXX source code.                               *
  *                                                            *
  * Syntax:    load_info = loadispf()                          *
  *            rc = dropispf(load_info)                        *
  *                                                            *
  *            The inline ISPF resources are limited to        *
  *            ISPF Messages, Panels, and Skeletons,           *
  *                 CLISTs and EXECs are also supported.       *
  *                                                            *
  *            The inline resources must start in column 1     *
  *            and use the following syntax:                   *
  *                                                            *
  *            >START    used to indicate the start of the     *
  *                      inline data                           *
  *                                                            *
  *            >END    - used to indicate the end of the       *
  *                      inline data                           *
  *                                                            *
  *            Each resource begins with a type record:        *
  *            >type name                                      *
  *               where type is CLIST, EXEC, MSG, PANEL, SKEL  *
  *                     name is the name of the element        *
  *                                                            *
  * Sample usage:                                              *
  *          -* rexx *-                                        *
  *          load_info = loadispf()                            *
  *          ... magic code happens here (your code) ...       *
  *          rc = dropispf(load_info)                          *
  *          exit                                              *
  *          >Start inline elements                            *
  *          >Panel panel1                                     *
  *          ...                                               *
  *          >Msg msg1                                         *
  *          ...                                               *
  *          >End of inline elements                           *
  *                                                            *
  * Returns:   the list of ddnames allocated for use along     *
  *            with the libdef's performed or altlib           *
  *                                                            *
  *            format is ddname libdef ddname libdef ...       *
  *                   libdef may be altlibc or altlibe         *
  *                   for altlib clist or altlib exec          *
  *                                                            *
  * Notes:     Entire routine must be included with REXX       *
  *            exec - inline with the code.                    *
  *                                                            *
  * Comments:  The entire rexx program is processed from the   *
  *            last record to the first to find the >START     *
  *            record at which point all records from that     *
  *            point on are processed until the >END           *
  *            statement or the end of the program is found.   *
  *                                                            *
  *            It is *strongly* suggested that the inline      *
  *            elements be at the very end of your code so     *
  *            that the search for them is faster.             *
  *                                                            *
  *            Inline ISPTLIB or ISPLLIB were not supported    *
  *            because the values for these would have to be   *
  *            in hex.                                         *
  *                                                            *
  * Author:    Lionel B. Dyck                                  *
  *                                                            *
  * History:                                                   *
  *            01/09/19 - Include DROPISPF routine             *
  *            08/29/17 - Fixup static values that were vars   *
  *            05/31/17 - Change default directory count       *
  *            12/09/16 - update for add_it routine            *
  *            05/10/16 - correction for clist and exec        *
  *            04/19/16 - bug correction                       *
  *            06/04/04 - Enhancements for speed               *
  *            08/05/02 - Creation                             *
  *                                                            *
  * ---------------------------------------------------------- *
  * Disclaimer: There is no warranty, either explicit or       *
  * implied with this code. Use it at your own risk as there   *
  * is no recourse from either the author or his employeer.    *
  * ---------------------------------------------------------- */
LoadISPF: Procedure

  parse value "" with null kmsg kpanel kskel first returns ,
    kclist kexec
  /* ------------------------------------------------------- *
  * Find the InLine ISPF Elements and load them into a stem *
  * variable.                                               *
  *                                                         *
  * Elements keyword syntax:                                *
  * >START - start of inline data                           *
  * >CLIST name                                             *
  * >EXEC name                                              *
  * >MSG name                                               *
  * >PANEL name                                             *
  * >SKEL name                                              *
  * >END   - end of all inline data (optional if last)      *
  * ------------------------------------------------------- */
  last_line = sourceline()
  do i = last_line to 1 by -1
    line = sourceline(i)
    if translate(left(line,6)) = ">START " then leave
  end
  rec = 0
  /* --------------------------------------------------- *
  * Flag types of ISPF resources by testing each record *
  * then add each record to the data. stem variable.    *
  * --------------------------------------------------- */
  do j = i+1 to last_line
    line = sourceline(j)
    if translate(left(line,5)) = ">END "   then leave
    if translate(left(line,7)) = ">CLIST " then kclist = 1
    if translate(left(line,6)) = ">EXEC "  then kexec  = 1
    if translate(left(line,5)) = ">MSG "   then kmsg   = 1
    if translate(left(line,7)) = ">PANEL " then kpanel = 1
    if translate(left(line,6)) = ">SKEL "  then kskel  = 1
    rec  = rec + 1
    data.rec = line
  end

  /* ----------------------------------------------------- *
  * Now create the Library and Load the Member(s)         *
  * ----------------------------------------------------- */
  Address ISPExec
  /* ----------------------------- *
  * Assign dynamic random ddnames *
  * ----------------------------- */
  clistdd = "lc"random(999)
  execdd  = "le"random(999)
  msgdd   = "lm"random(999)
  paneldd = "lp"random(999)
  skeldd  = "ls"random(999)

  /* ---------------------------------------- *
  *  LmInit and LmOpen each resource library *
  * ---------------------------------------- */
  if kclist <> null then do
    call alloc_dd clistdd
    "Lminit dataid(clist) ddname("clistdd")"
    "LmOpen dataid("clist") Option(Output)"
    returns = strip(returns clistdd 'ALTLIBC')
  end
  if kexec <> null then do
    call alloc_dd execdd
    "Lminit dataid(exec) ddname("execdd")"
    "LmOpen dataid("exec") Option(Output)"
    returns = strip(returns execdd 'ALTLIBE')
  end
  if kmsg <> null then do
    call alloc_dd msgdd
    "Lminit dataid(msg) ddname("msgdd")"
    "LmOpen dataid("msg") Option(Output)"
    returns = strip(returns msgdd 'ISPMLIB')
  end
  if kpanel <> null then do
    call alloc_dd paneldd
    "Lminit dataid(panel) ddname("paneldd")"
    "LmOpen dataid("panel") Option(Output)"
    returns = strip(returns paneldd 'ISPPLIB')
  end
  if kskel <> null then do
    call alloc_dd skeldd
    "Lminit dataid(skel) ddname("skeldd")"
    "LmOpen dataid("skel") Option(Output)"
    returns = strip(returns skeldd 'ISPSLIB')
  end

  /* ----------------------------------------------- *
  * Process all records in the data. stem variable. *
  * ----------------------------------------------- */
  do i = 1 to rec
    record = data.i
    recordu = translate(record)
    if left(recordu,5) = ">END " then leave
    if left(recordu,7) = ">CLIST " then do
      if first = 1 then call add_it
      type = "Clist"
      first = 1
      parse value record with x name
      iterate
    end
    if left(recordu,6) = ">EXEC " then do
      if first = 1 then call add_it
      type = "Exec"
      first = 1
      parse value record with x name
      iterate
    end
    if left(recordu,5) = ">MSG " then do
      if first = 1 then call add_it
      type = "Msg"
      first = 1
      parse value record with x name
      iterate
    end
    if left(recordu,7) = ">PANEL " then do
      if first = 1 then call add_it
      type = "Panel"
      first = 1
      parse value record with x name
      iterate
    end
    if left(recordu,6) = ">SKEL " then do
      if first = 1 then call add_it
      type = "Skel"
      first = 1
      parse value record with x name
      iterate
    end
    /* --------------------------------------------*
    * Put the record into the appropriate library *
    * based on the record type.                   *
    * ------------------------------------------- */
    Select
      When type = "Clist" then
      "LmPut dataid("clist") MODE(INVAR)" ,
        "DataLoc(record) DataLen(255)"
      When type = "Exec" then
      "LmPut dataid("exec") MODE(INVAR)" ,
        "DataLoc(record) DataLen(255)"
      When type = "Msg" then
      "LmPut dataid("msg") MODE(INVAR)" ,
        "DataLoc(record) DataLen(80)"
      When type = "Panel" then
      "LmPut dataid("panel") MODE(INVAR)" ,
        "DataLoc(record) DataLen(80)"
      When type = "Skel" then
      "LmPut dataid("skel") MODE(INVAR)" ,
        "DataLoc(record) DataLen(80)"
      Otherwise nop
    end
  end
  if type <> null then call add_it
  /* ---------------------------------------------------- *
  * Processing completed - now lmfree the allocation and *
  * Libdef the library.                                  *
  * ---------------------------------------------------- */
  if kclist <> null then do
    Address TSO,
      "Altlib Act Application(Clist) File("clistdd")"
    "LmFree dataid("clist")"
  end
  if kexec <> null then do
    Address TSO,
      "Altlib Act Application(Exec) File("execdd")"
    "LmFree dataid("exec")"
  end
  if kmsg <> null then do
    "LmFree dataid("msg")"
    "Libdef ISPMlib Library ID("msgdd") Stack"
  end
  if kpanel <> null then do
    "Libdef ISPPlib Library ID("paneldd") Stack"
    "LmFree dataid("panel")"
  end
  if kskel <> null then do
    "Libdef ISPSlib Library ID("skeldd") Stack"
    "LmFree dataid("skel")"
  end
  return returns

  /* --------------------------- *
  * Add the Member using LmmAdd *
  * based upon type of resource *
  * --------------------------- */
Add_It:
  Select
    When type = "Clist" then
    "LmmAdd dataid("clist") Member("name")"
    When type = "Exec" then
    "LmmAdd dataid("exec") Member("name")"
    When type = "Msg" then
    "LmmAdd dataid("msg") Member("name")"
    When type = "Panel" then
    "LmmAdd dataid("panel") Member("name")"
    When type = "Skel" then
    "LmmAdd dataid("skel") Member("name")"
    Otherwise nop
  end
  type = null
  return

  /* ------------------------------ *
  * ALlocate the temp ispf library *
  * ------------------------------ */
Alloc_DD:
  arg dd
  Address TSO
  if pos(left(dd,2),"lc le") > 0 then
  "Alloc f("dd") unit(sysda) spa(5,5) dir(5)",
    "recfm(v b) lrecl(255) blksize(32760)"
  else
  "Alloc f("dd") unit(sysda) spa(5,5) dir(5)",
    "recfm(f b) lrecl(80) blksize(23440)"
  return

  /* --------------------  rexx procedure  -------------------- *
  * Name:      DropISPF                                        *
  *                                                            *
  * Function:  Remove ISPF LIBDEF's and deactivate ALTLIB's    *
  *            that were created by the LoadISPF function.     *
  *                                                            *
  * Syntax:    rc = dropispf(load_info)                        *
  *                                                            *
  * Author:    Janko                                           *
  *                                                            *
  * History:                                                   *
  *            12/05/18 - Creation                             *
  * ---------------------------------------------------------- */
DropISPF: Procedure
  arg load_info
  Address ISPEXEC
  do until length(load_info) = 0
    parse value load_info with dd libd load_info
    if left(libd,6) = "ALTLIB" then do
      if libd = "ALTLIBC" then lib = "CLIST"
      else lib = "EXEC"
      Address TSO,
        "Altlib Deact Application("lib")"
    end
    else "libdef" libd
    address tso "free f("dd")"
  end
  return 0
>ZGSTATE    *** End of the ZGSTAT inline code
