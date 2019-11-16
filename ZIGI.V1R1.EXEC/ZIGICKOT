  /*%NOcomment ----------  rexx procedure  -------------------- *
  | Name:      zigickot                                        |
  |                                                            |
  | Function:  zigi Checkout                                   |
  |                                                            |
  | Syntax:    %zigickot                                       |
  |                                                            |
  | Usage Notes:                                               |
  |            1. ISPF Variables will pass the                 |
  |               - default HLQ to be used                     |
  |            2. The OMVS Directory where the project is      |
  |            3. Sequential files that have no lowercase      |
  |               will be processed.                           |
  |                                                            |
  | Author:    Lionel B. Dyck                                  |
  |                                                            |
  | History:  (most recent on top)                             |
  |            11/16/19 LBD - Change to use ZIGISTAT routine   |
  |            10/30/19 LBD - Get DCB info from /.zigi/dsn     |
  |            10/28/19 LBD - Support sequential files         |
  |            06/12/19 LBD - Correct to handle a git direcory |
  |            06/11/19 LBD - Add popup status                 |
  |            06/10/19 LBD - Creation                         |
  |                                                            |
  * ---------------------------------------------------------- */

  /* -------------------------------------------- *
  | Get the ISPF Variables with our instructions |
  * -------------------------------------------- */
  Address ISPExec
  'vget (ckothlq ckotdir)'
  Address TSO

  /* -------------------- *
  | Issue the LS command |
  * -------------------- */
  cmd = 'ls -laRk' ckotdir
  rc = bpxwunix(cmd,,stdout.,stderr.)

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
  parse value '' with subs files null
  hit = 0

  /* ------------------------------------ *
  | Read in ../.zigi/dsn to get dcb info |
  * ------------------------------------ */
  call outtrap 'x.'
  ckdd = 'ck'time('s')
  if sysvar('syspref') = null then pref = sysvar('sysuid')'.'
  else pref = null
  call outtrap 'x.'
  "oget '"ckotdir"/.zigi/dsn'" ckdd 'text'
  'Alloc f('ckdd') shr ds('ckdd')'
  'Execio * diskr' ckdd '(finis stem ck.'
  'Free f('ckdd')'
  'delete' ckdd
  def. = null
  call outtrap 'off'
  do i = 1 to ck.0
    if left(ck.i,1) = '#' then iterate
    if word(ck.i,1) = '*' then do
      parse value ck.i with . def_dsorg def_recfm def_lrecl def_blksize .
    end
    else do
      dsn = word(ck.i,1)
      def.dsn = subword(ck.i,2)
    end
  end

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
          if left(sub,1) /= '.' then
          subs = subs sub
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

  /* -------------------------------------------- *
  | Process the individual files, if any         |
  | Allocation and Copy                          |
  * -------------------------------------------- */
  do i = 1 to words(files)
    parse value '' with zs1 zs2 zs3 zs4 zs5 zs6 zs7 zs8
    zs9 = 'Patience while the data is copied from OMVS files' ,
      'to a z/OS PDS.'
    sub = word(files,i)
    fileg = "'"ckothlq"."sub"'"
    odir = "'"ckotdir"/"sub"'"
    zs1 = 'Processing file:' sub
    zs2 = 'From:           ' odir
    zs3 = 'To:             ' fileg
    call pop_status
    call outtrap 'x.'
    if sysdsn(fileg) = 'OK' then
    'delete' fileg
    tracks =  (size.sub%50000 + 1) * 2
    sub = fileg
    call get_dcb
    'alloc ds('fileg') new spa('tracks','tracks') tr dsorg(ps)' ,
      'recfm('recfm') lrecl('lrecl') blksize('blksize')'
    'free ds('fileg')'
    fileg = translate(fileg,' ','.')
    m = strreplace(fileg,'.','#')
    m = strreplace(m,'_','@')
    m = strreplace(m,'-','$')
    m = translate(fileg,'.',' ')
    call outtrap 'x.'
    'oget' odir m 'text'
    call outtrap 'off'
  end

  /* -------------------------------------------- *
  | Process the sub-directories and initiate the |
  | Allocation and Copy                          |
  * -------------------------------------------- */
  do i = 1 to words(subs)
    parse value '' with zs1 zs2 zs3 zs4 zs5 zs6 zs7 zs8
    zs9 = 'Patience while the data is copied from OMVS files' ,
      'to a z/OS PDS.'
    sub = word(subs,i)
    zs1 = 'Processing subdirectory:' sub
    zs2 = 'Members:                ' dir.sub
    zs3 = 'Total bytes (k):        ' size.sub
    tracks =  (size.sub%50000 + 1) * 2
    zs4 = 'Tracks allocated:       ' tracks
    call pop_status
    call alloc_copy_pds
    call add_stats
  end

  Exit

  /* ---------------------------------------------- *
  | Allocate the PDS and perform the copy (OGETX)  |
  | - the PDS will be allocated as a PDSE          |
  | - if the target PDS exists delete and realloc  |
  * ---------------------------------------------- */
Alloc_Copy_PDS:
  pds = "'"ckothlq"."sub"'"
  odir = "'"ckotdir"/"sub"/"
  zs8 = ''
  if sysdsn(pds) = 'OK' then do
    zs8 = 'Re-Allocating'
    call outtrap 'x.'
    'delete' pds
    call outtrap 'off'
  end
  zs5 = 'Allocating PDSE:        ' pds
  call pop_status
  call get_dcb
  'Alloc new spa('tracks','tracks') recfm('recfm') lrecl('lrecl')' ,
    'Blksize('blksize') Dsntype(Library,2) dsorg(po) dir(1)' ,
    'dsn('pds')'
  'Free ds('pds')'
  zs6 =  'Populating from:        ' odir
  call pop_status
  /* ---------------------------------------------------- *
  | Read directory to get all member file names and then |
  | adjust according and then do individual oget         |
  * ---------------------------------------------------- */
  target = strip(pds,'B',"'")
  call syscalls 'ON'
  address syscall
  rdir = strip(odir,'B',"'")
  'readdir' rdir 'mems.'
  address ispexec
  call outtrap 'x.'
  do ii = 1 to mems.0
    if mems.ii = "." | mems.ii = ".." then do
      /* skip the . and .. things */
      iterate
    end
    src = rdir'/'mems.ii
    /* fix the cp -M behavior on the way in */
    m = strreplace(mems.ii,'.','#')
    m = strreplace(m,'_','@')
    m = strreplace(m,'-','$')
    Address TSO
    'OGET' "'"src"'" "'"target"("m")'"
    Address ISPexec
  end
  call outtrap 'off'
  return

get_dcb:
  if def.sub /= null then do
    parse value def.sub with dsorg recfm lrecl blksize
    recfm = left(recfm,1) substr(recfm,2,1) substr(recfm,3,1)
  end
  else do
    recfm = left(def_recfm,1) substr(def_recfm,2,1) substr(def_recfm,3,1)
    lrecl = def_lrecl
    blksize = def_blksize
  end
  return

  /* ------------ *
  | PopUp Status |
  * ------------ */
Pop_Status:
  Address ISPExec
  call pfshow 'off'
  'Control Display Lock'
  'Addpop row(4) column(2)'
  'Display Panel(zigipopc)'
  'Rempop'
  call pfshow 'reset'
  Address TSO
  return

  /* ---------------------------------- *
  | Add ISPF Statistics to all Members |
  | - set the initial userid to ZIGI   |
  * ---------------------------------- */
Add_Stats:
  zs7 = 'Adding ISPF Statistics  '
  call pop_status
  filepath = ckotdir'/.zigi/'sub
  '%zigistat' pds filepath 'U'
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

strreplace: Procedure
  string  = arg(1)
  strfrom = arg(2)
  strto   = arg(3)
  if pos(strfrom,string) = 0 then return string
  newString = ''
  do i = 1 to length(string)
    if substr(string,i,1) /= strfrom
    then newstring = newstring''substr(string,i,1)
    else  newstring = newstring''strto
  end
  return newstring
