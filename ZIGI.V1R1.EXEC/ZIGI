  /*%NOcomment ----------  rexx procedure  ------------------- */
  ver = 'v1r1'
  /*Name:      zigi  (z ISPF Git Interface)                    |
  |                                                            |
  | Version:   V1R1                                            |
  |                                                            |
  | Function:  ISPF Interface to Git for source code           |
  |            management                                      |
  |                                                            |
  | Syntax:    ex 'zigi.v1r0.exec(zigi)'                       |
  |                                                            |
  | NOTE:      ZIGI MUST NEVER be started under the ZIGI       |
  |            ISPF Applications ID.                           |
  |                                                            |
  | Dependencies:                                              |
  |            1. Requires the z/OS port of GIT be installed   |
  |            2. Git setup in /etc/profile or ~/.profile      |
  |                                                            |
  | Authors:   Henri Kuiper                                    |
  |            Lionel B. Dyck                                  |
  |                                                            |
  | History:  (most recent on top, see git log for full info)  |
  |                                                            |
  |            11/21/09 LBD - Check for ISPTABL and use it     |
  |                           otherwise use ISPPROF for our    |
  |                           table.                           |
  |            11/18/09 LBD - Support F3 in ZIGIOSEL and       |
  |                           skip clone.                      |
  |                         - Replace LMMSTATS with LMMFIND    |
  |                           to get member stats              |
  |                         - Add -v (verbose) where ok        |
  |            11/16/09 LBD - Convert to using zigitstat       |
  |                           to save/update/compare           |
  |                           ispf stats on PDS members.       |
  |            11/13/09 LBD - Enhance the debug routine:       |
  |                           Return a return code             |
  |                           check for ZIGIDEBG DD enable     |
  |                           log is in users home dir         |
  |            11/11/09 LBD - Add GITHELP as a command from    |
  |                           all panels (except browse)       |
  |            11/10/09 HBK - Fix qualignr edge-cases          |
  |            11/09/09 HBK - My history keeps dissapearing    |
  |                           see git :)                       |
  |            11/06/19 LBD - Numerous changes including       |
  |                           - Improve bpxwunix performance   |
  |                             by using an env stem           |
  |                           - fix lrecl for browse reports   |
  |                           - other bug fixes and cleanup    |
  |            11/02/19 LBD - Add shorten ZIGIREPO panel       |
  |                           ZIGIREPS if SHort command used   |
  |            10/31/19 LBD - Various Fixes :)                 |
  |            10/29/19 LBD - Add MultiDCB Support             |
  |            10/24/19 HBK - Also source ~/.profile if exists |
  |            10/24/19 LBD - Change 2 routines to procedure   |
  |                         - Add Commit message               |
  |            10/21/19 LBD - Use PARSE SOURCE for hlq         |
  |            10/20/19 HBK - Fix LMM things :)                |
  |            10/19/19 LBD - Better prefix, scrolling etc.    |
  |            10/17/19 HBK - Add back LMM, cleanup code       |
  |            09/30/19 HBK - Major rewrite :)                 |
  |            07/24/19 HBK - Some git functions               |
  |            06/15/19 HBK - Autofind git binary              |
  |            06/14/19 LBD - Major updates                    |
  |            06/12/19 LBD - Major updates                    |
  |            06/11/19 LBD - Creation                         |
  |                                                            |
  | ---------------------------------------------------------- |
  |   Copyleft (C) 2019                                        |
  * ---------------------------------------------------------- */
  Address ISPExec
  'vget (zapplid)'

  /* ---------------------------------------- *
  | Check for ZIGIDEBG DD for debug purposes |
  * ---------------------------------------- */
  x = listdsi('ZIGIDEBG' 'FILE')
  if x > 0 then if sysreason = 3 then zigidebg = 1
  else zigidebg = 0
  if zigidebg = 0 then
  "Control Errors Return"

  parse value '' with null rx zigidebg_flag
  /* ----------------------------------------------------- *
  | Get the Active HLQ for use with the ALTLIB and LIBDEF |
  | of the zIGI libraries.                                |
  | 1st Get the active exec library or dd                 |
  * ----------------------------------------------------- */
  parse source x1 x2 x3 x4 exec .
  if exec = '?' then do
    x = listdsi(x4 'FILE')
    exec = sysdsname
  end
  /* ------------------------------------------ *
  | Now extract the HLQ for the Panels Library |
  * ------------------------------------------ */
  zigihlq = translate(exec,' ','.')
  zigihlq = subword(zigihlq,1,words(zigihlq)-1)
  zigihlq = translate(zigihlq,'.',' ')
  /* ---------------------------------------------- *
  | Fully qualify the EXEC and PANELS library dsns |
  * ---------------------------------------------- */
  exec = "'"exec"'"
  panels = "'"zigihlq".PANELS'"

  /* ---------------------------------------- *
  | If panels/exec then libdef and/or altlib |
  | but only if not under ZIGI applid.       |
  * ---------------------------------------- */
  if zapplid /= 'ZIGI' then do
    if panels /= null then
    'libdef ispplib dataset id('panels') stack'
    if exec /= null then
    Address TSO 'altlib act application(exec) dataset('exec')'
  end

  /* ----------------------------------------------------------- *
  | Check for running under the ZIGI ISPF application ID and if |
  | not then recurse into it.                                   |
  * ----------------------------------------------------------- */
  if zapplid <> "ZIGI" then do
    /* --------------------------------------- *
    | Make sure we are under the ZIGI applid  |
    * --------------------------------------- */
    "Select CMD(%zigi) Newappl(ZIGI) Passlib"
    if panels /= null then
    'libdef ispplib'
    if exec /= null then
    Address TSO 'altlib deact application(exec)'
    exit 0
  end

  /* ---------------------------------------------------------------- *
  | Running under the ZIGI ISPF Application ID so let's do some work |
  * ---------------------------------------------------------------- */
  zcmd = null
  zigtitle = '(zigi' ver')'
  'vput (zigtitle ver)'
  'display panel(zigispls)'
  if rc = 8 then exit

  /* ------------------------------------ *
  | define our working default variables |
  * ------------------------------------ */
  zerrhm   = 'zigih00'
  zerralrm = 'NO'
  zerrtp   = 'NOTIFY'
  zs1 = 'Preparing the zigi environment for use'
  zs2 = 'Please standby'
  call do_popup
  cmd = 'pwd'
  x = bpxwunix(cmd,,so.,se.)
  home    = strip(so.1)
  call getenv
  keyfile = home'/.ssh/id_rsa.pub'
  rtbl = 'ZIGL'random(9999)
  rtll = 'ZIGM'random(9999)
  rtbb = 'ZIGB'random(9999)
  rtbl_open = 0

  /* ------------------------------------ *
  | Let's try to find git.               |
  * ------------------------------------ */
  zs1 = 'Checking if you have git installed'
  zs2 = 'Please standby'
  call do_popup

  x   = docmd('command -v git')

  if so.0 = 1 then do
    zigigitl = strip(so.1)
    'vput (zigigitl) profile'
  end
  else do
    /* needs a nice error panel with a link to download git */
    zs1 = "Git not installed, or not in path. Check /etc/profile"
    zs2 = "Download via rocket, see installer on github gists."
    call do_popup
    exit(0)
  end

  /* ------------------------------------------ *
  | Check for GIT Userid and if not found      |
  | then prompt for it along with a GIT E-Mail |
  | Find the SSH key and if not there generate |
  * ------------------------------------------ */
  zs1 = 'Checking for user.name and user.email'
  zs2 = 'Please standby'
  call do_popup
  x = docmd('git config --global user.name')
  if x = 0 then do
    zigiuid = so.1
  end
  else do
    zigiuid = null
  end
  x = docmd('git config --global user.email')

  if x = 0 then do
    zigimail = so.1
  end
  else do
    zigimail = null
  end
  cmd = 'cat 'home'/.ssh/id_rsa.pub'
  x = bpxwunix(cmd,,so.,se.)
  if x > 0 then do
    zs1 = 'No SSH identity found in 'home'/.ssh/id_rsa'
    zs2 = 'Generating keypair, please standby'
    call do_popup
    cmd = 'mkdir -p 'home'/.ssh'
    x = bpxwunix(cmd,,so.,se.)
    cmd = 'cd 'home' && ssh-keygen -t rsa -f .ssh/id_rsa'
    x = bpxwunix(cmd,,so.,se.)
    cmd = 'cat 'home'/.ssh/id_rsa.pub'
    x = bpxwunix(cmd,,so.,se.)
  end
  zigissh = so.1
  /* need these to see if changed, then we need to
  redo the command...... @lionel: there's probably
  a nicer way to do this (via the panel that sees if
  the value has changed?
  */
  old_zigiuid = zigiuid
  old_zigimail = zigimail
  /* end of save old values */

  /* this needs refactored :) */
  if zigiuid = null | zigimail = null then do
    hit = 0
  end
  else do
    hit = 1
  end
  do forever
    if hit = 1 then leave
    'Display Panel(zigiset)'
    /* dunno if we still need these in the profile?? */
    'VPut (zigiuid zigimail zigissh) Profile'
    /* maybe we could use the ispprof for some lazy caching */
    /* now that we've had the user see the settings.
    set the git config if they have changed...
    */
    if old_zigiuid /= zigiuid then do
      x = docmd('git config --global user.name "'zigiuid'"')
      if x > 0 then do
        zs1 = "something went wrong with git config user.name"
        zs2 = so.1
        zs3 = se.1
        zs4 = ''
        call do_popup4
      end
      x = docmd('git config --global user.email "'zigimail'"')
      if x > 0 then do
        zs1 = "something went wrong with git config user.email"
        zs2 = so.1
        zs3 = se.1
        zs4 = ''
        call do_popup4
      end
      /* Let's adopt the new style. Only push current branch */
      x = docmd('git config --global push.default simple')
    end
    'VPut (zigiuid zigimail zigissh) Profile'
    zerrsm = 'Updated.'
    zerrlm = 'zIGI Settings updated successfully.'
    'Setmsg msg(isrz003)'
    if zigiuid /= null
    then if zigimail /= null
    then if zigissh /= null
    then do forever
      zcmd = null
      'Display Panel(zigisshk)'
      if rc > 0 then do
        hit = 1
        leave
      end
    end
  end

  /* ---------------------------------------- *
  | Open (or create and open) the Repo Table |
  * ---------------------------------------- */
  isptabl = 'ISPTABL'
  x = listdsi(isptabl 'FILE')
  if x > 0 then isptabl = 'ISPPROF'
  'TBOpen zigirepo Library('isptabl') Write Share'
  if rc > 0 then do
    if rc = 8 then call create_zigirepo
    if rc > 8 then do
      'setmsg msg(isrz003)'
    end
  end

  /* --------------------------------------------- *
  | Test to see if the ZIGIREPO table is for V1R1 |
  * --------------------------------------------- */
  'tbquery zigirepo keys(keys)'
  if keys = '(ZIGIREP)' then do
    'tbtop zigirepo'
    tc = 0
    do forever
      'tbskip zigirepo'
      if rc > 0 then leave
      tc = tc + 1
      key.tc = localrep pdshlq qualignr zigirep
    end
    tc.0 = tc
    'tbend zigirepo'
    'TBErase zigirepo Library('isptabl')'
    call create_zigirepo
    do i = 1 to tc.0
      parse value key.i with localrep pdshlq qualignr zigirep
      zigikey = localrep'/'zigirep
      'tbadd zigirepo order'
    end
  end

  repo_top = 1
  'tbtop zigirepo'
  "TBSort zigirepo Fields(zigirep,C,A)"
  'vget (primpanl) profile'
  if primpanl = null then primpanl = 'zigiprim'
  do forever
    parse value '' with zsel zcmd row
    'TBTop zigirepo'
    'tbskip zigirepo number('repo_top')'
    'tbdispl zigirepo panel('primpanl')'
    if rc > 4 then leave

    repo_top = ztdtop
    if row = 0 then zsel = null
    if row <> null then
    if row > 0 then do
      'TBTop zigirepo'
      'TBSkip zigirepo Number('row')'
    end

    if abbrev('BASIC',zcmd,2) = 1 then zcmd = 'PRO'
    if zcmd /= null then
    Select
      When abbrev('GITHELP',zcmd,4) = 1 then
      Address TSO '%githelp'
      When abbrev('CREATE',zcmd,2) = 1 then do
        x = Create_Repo()
        if x = 0 then
        call work_with_repo
        zsel = null
      end
      When abbrev('CLONE',zcmd,2) = 1 then do
        call Clone_Repo
        zsel = null
      end
      When abbrev('CONFIG',zcmd,2) = 1 then do forever
        zcmd = null
        'display panel(zigiset)'
        /* TODO: Add code to apply the new settings..... */
        if rc = 0 | rc = 8 then leave
      end
      When abbrev('PRO',zcmd,2) = 1 then do
        if primpanl = 'zigiprim'
        then primpanl = 'zigiprms'
        else primpanl = 'zigiprim'
        'vput (primpanl) profile'
      end
      When abbrev('SSH',zcmd,2) = 1 then do forever
        zcmd = null
        'display panel(zigisshk)'
        if rc > 0 then leave
      end
      Otherwise do
        zerrsm = 'Unknown'
        zerrlm = zcmd 'is not a recognized command.'
        'setmsg msg(isrz003)'
      end
    end

    if zsel /= null then
    Select
      When zsel = 'S' then call Work_With_Repo
      When zsel = 'V' then do
        'SELECT PGM(ISRDSLST) PARM(UDL' localrep'/'zigirep') SUSPEND'
      end
      When zsel = 'D' then do
        /* delete the repo. Maybe needs a 'are you sure' :)
        for now. we delete the table from ispfprof and
        make sure we cleanup the repodir...
        does not touch z/OS datasets                   */
        cmd = 'cd' localrep' && rm -rf 'zigirep
        x = bpxwunix(cmd,,so.,se.)
        'tbdelete zigirepo'
        zerrsm = 'Deleted.'
        zerrlm = 'The local repository has been deleted from zIGI' ,
          'and all OMVS files and directory were deleted. The z/OS' ,
          'datasets remain.' localrep'/'zigirep
        'setmsg msg(isrz003)'
      end
      Otherwise do
        zerrsm = 'Unknown'
        zerrlm = zsel 'is not a recognized command.'
        'setmsg msg(isrz003)'
      end
    End
  end

  if rtbl_open = 1 then
  'tbend' rtbl
  'tbclose zigirepo'
  if zigidebg = 1 then
  if zigidebg_use = 1 then
  "Select Cmd(OBrowse '"home"/zigidebug.txt')"
  Exit 0

  /* ------------------------------ *
  | Create the ZIGIREPO ISPF Table |
  * ------------------------------ */
Create_zigirepo:
  "TBCreate zigirepo Keys(zigikey)",
    "Names(zigirep localrep pdshlq qualignr)",
    'Library('isptabl') Write Share'
  "TBSort zigirepo Fields(zigirep,C,A)"
  'TBSAVE zigirepo REPLCOPY LIBRARY('isptabl')'
  return

  /* --------------------------------- *
  | Work with the selected repository |
  * --------------------------------- */
Work_With_Repo:
  parse value '' with dsn dsnstat zsel ztdsels rtop
  call update_repo_metadata
  'tbsort' rtbl 'Fields(fulldsn,c,a)'
  'tbtop' rtbl
  /* -------------------------------- *
  | Process the Repository Data Sets |
  * -------------------------------- */
  'vget (repopan) profile'
  if repopan = null then repopan = 'zigirepo'
  rtop = 0
  do forever
    parse value '' with zsel zcmd row
    if ztdsels > 0
    then 'TBdispl' rtbl
    else do
      'tbtop' rtbl
      'tbskip' rtbl 'Number('rtop')'
      'TBdispl' rtbl 'Panel('repopan')'
      rtop = ztdtop
    end
    if rc > 4 then do
      'tbend' rtbl
      rtbl_open = 0
      return
    end
    drop so. se.
    zcmd = translate(zcmd)

    if row = 0 then zsel = null
    if row <> null then
    if row > 0 then do
      "TBTop " rtbl
      "TBSkip" rtbl "Number("row")"
    end

    if abbrev('BASIC',zcmd,2) = 1 then zcmd = 'PRO'
    if zcmd /= null then
    Select
      When abbrev('VIEW',zcmd,1) = 1 then
      'SELECT PGM(ISRDSLST) PARM(UDL' localrep'/'zigirep') SUSPEND'
      When abbrev('GITHELP',zcmd,4) = 1 then
      Address TSO '%githelp'
      When abbrev('PRO',zcmd,2) = 1 then do
        if repopan = 'zigirepo'
        then repopan = 'zigireps'
        else repopan = 'zigirepo'
        'vput (repopan) profile'
      end
      When abbrev('BRANCH',zcmd,2) = 1 then call Branch_it
      /* -------------------------------- *
      | View output of git log           |
      * -------------------------------- */
      When abbrev('GITLOG',zcmd,2) = 1 then call do_gitlog
      /* -------------------------------- *
      | Push current branch to origin    |
      * -------------------------------- */
      When abbrev('PUSH',zcmd,2) = 1 then call do_push
      /* --------------------------------------------------------- *
      | Pull latest version of remote current branch from origin  |
      * --------------------------------------------------------- */
      When abbrev('PULL',zcmd,3) = 1 then do
        call pop 'Pulling from remote'
        cmd = 'cd' localdir' && git pull -v'
        x = docmd(cmd)
        call view_std 'B'
        call Refresh localrep zigirep pdshlq qualignr
        call update_repo_metadata
      end
      /* --------------------------------------------------------- *
      | Add a PDS or a Sequential File to "Working Directory"     |
      * --------------------------------------------------------- */
      When abbrev('ADD',zcmd,3) = 1 then do
        call Add_Dataset
      end
      /* -------------------------------- *
      | View output of git status        |
      * -------------------------------- */
      When abbrev('STATUS',zcmd,2) = 1 then call do_status
      /* -------------------------------- *
      | Refresh z/OS datasets            |
      * -------------------------------- */
      When abbrev('REFRESH',zcmd,3) = 1 then do
        zcmd = null
        call Refresh localrep zigirep pdshlq qualignr
        call update_repo_metadata
      end
      /* -------------------------------- *
      | GIT GREP                         |
      * -------------------------------- */
      When abbrev('GREP',zcmd,3) = 1 then do forever
        parse value  '' with zcmd grepstr
        'display panel(zigigrep)'
        if rc > 0 then leave
        if rc = 0 then do
          cmd = 'cd' localrep'/'zigirep
          x = docmd(cmd '&& git grep "'grepstr'"')
          if x = 1 then do
            zerrsm = ''
            zerrlm = 'grep search found nothing.'
            'setmsg msg(isrz003)'
          end
          else  call View_std 'B'
        end
      end

      /* -------------------------------- *
      | Commit to current branch         |
      * -------------------------------- */
      When abbrev('COMMIT',zcmd,3) = 1 then call do_commit
      /* -------------------------------- *
      | Add/replace remote URI (origin)  |
      * -------------------------------- */
      When abbrev('REMOTE',zcmd,3) = 1 then do
        zcmd = null
        'display panel(zigiremo)'
        if rc > 0 then do
          zerrsm = 'Cancelled.'
          zerrlm = 'Remote update cancelled.'
          'setmsg msg(isrz003)'
        end
        else do
          parse var origin guser '@' host ':' rest
          cmd = 'touch 'home'/.ssh/known_hosts && '
          cmd = cmd 'ssh-keyscan -t rsa,dsa 'host
          cmd = cmd ' 2>&1 | sort -u - 'home'/.ssh/known_hosts >'
          cmd = cmd ' 'home'/.ssh/tmp_hosts && '
          cmd = cmd 'mv 'home'/.ssh/tmp_hosts 'home'/.ssh/known_hosts'
          x = bpxwunix(cmd,,so.,se.)
          cmd = 'cd' localrep'/'zigirep
          x = docmd(cmd '&& git remote add origin 'origin)
          call View_std 'B'
          cmd = 'cd' localrep'/'zigirep
          cmd = docmd(cmd '&& git push -vu origin 'branch)
          call View_std 'B'
          call update_repo_metadata
        end
      end
      Otherwise do
        zerrsm = 'Unknown'
        zerrlm = zcmd 'is not a recognized command.'
        'setmsg msg(isrz003)'
      end
    end

    if zsel /= null then
    Select
      When zsel = 'B' then do
        'control display save'
        x = listdsi(fulldsn)
        if sysdsorg = 'PO' then do
          'LMInit Dataid(zigdid) Dataset('fulldsn')'
          "Memlist Dataid("zigdid") Default(B)"
          "LMfree Dataid("zigdid")"
        end
        else 'Browse Dataset('fulldsn')'
        'control display restore'
      end
      When zsel = 'V' then do
        'control display save'
        x = listdsi(fulldsn)
        if sysdsorg = 'PO' then do
          'LMInit Dataid(zigdid) Dataset('fulldsn')'
          "Memlist Dataid("zigdid") Default(V)"
          "LMfree Dataid("zigdid")"
        end
        else 'View Dataset('fulldsn')'
        'control display restore'
      end
      /* -------------------------------- *
      | Work with a repo item            |
      * -------------------------------- */
      When zsel = 'S' & sysdsn(fulldsn) /= 'OK' then do
        zerrsm = 'Error'
        zerrlm = fulldsn 'does not exist. This should not have happened.' ,
          'Somehow it may have been deleted.'
        'Setmsg msg(isrz003)'
      end
      When zsel = 'S' then call work_with_repo_file
      /* -------------------------------- *
      | Add repo item to staging area    |
      * -------------------------------- */
      When zsel = 'A' then do
        zs1 = 'Adding' fulldsn
        zs2 = 'Making it ready to Commit'
        call do_popup
        d = usssafe(dsn)
        cmd = 'cd' localrep'/'zigirep
        x = docmd(cmd '&& git add -v 'd)
        call view_std 'B'
        if ztdsels = 1 then do
          statfile = translate(strip(fulldsn,'B',"'"),' ','.')
          statfile = subword(statfile,qualignr+1)
          statfile = translate(statfile,'.',' ')
          cmd = 'cd' localrep'/'zigirep'/.zigi/'
          x = docmd(cmd '&& git add -v 'statfile)
          call update_repo_metadata
        end
      end
      /* -------------------------------- *
      | Un-Modify entire dataset         |
      * -------------------------------- */
      When zsel = 'U' then do
        zs1 = 'Un-modiying ' fulldsn
        zs2 = 'This never happened...'
        call do_popup
        d = usssafe(dsn)
        cmd = 'cd' localrep'/'zigirep
        x = docmd(cmd '&& git checkout -- 'd)
        call view_std 'B'
        if ztdsels = 1 then do
          call update_repo_metadata
        end
      end
      Otherwise nop
    end
  end
  if ztdsels = 1 then do
    'tbend' rtbl
    rtbl_open = 0
    call work_with_repo
  end
  return

  /* ---------------------- *
  | Display the git Status |
  * ---------------------- */
Do_Status:
  zcmd = null
  cmd = 'cd' localrep'/'zigirep
  x = docmd(cmd '&& git status')
  call view_std
  return

  /* ------------------- *
  | Display the Git Log |
  * ------------------- */
Do_GitLog:
  zcmd = null
  zcmd = null
  call pfshow 'off'           /* make sure pfshow is off */
  'vget (lcnt logdfrom logdto greplog) profile'
  'Addpop row(4) column(6)'
  'Display Panel(zigilog)'
  'Rempop'
  call pfshow 'reset'         /* restore pfshow setting */
  lopts = null
  if lcnt /= null then lopts = '-n' lcnt
  if logdfrom /= null then lopts = lopts '--after="'logdfrom'"'
  if logdto   /= null then lopts = lopts '--until="'logdto'"'
  if greplog /= null then lopts = lopts '--grep='translate(greplog)
  lopts = translate(lopts,'-','/')
  cmd = 'cd' localdir' && git log --cc -m' lopts
  'vput (lcnt logdfrom logdto greplog) profile'
  x = docmd(cmd)
  if so.0 + se.0 > 1
  then call view_std
  else do
    zerrsm = ''
    zerrlm = 'GitLog filters resulted in an empty report.'
    'setmsg msg(isrz003)'
  end
  return

/* ----------------------------- *
 | Reset USERIDs for all members |
 * ----------------------------- */
Do_Resetid:
  call pfshow 'off'
  'Addpop row(4) column(12)'
  'display panel(zigirsid)'
  xrc = rc
  'Rempop'
  call pfshow 'reset'
  if xrc = 0 then do
    save_top = ztdtop
    'tbtop' rtll
    "LMINIT DATAID(zstats) DATASET("fulldsn")"
    "LMOPEN DATAID("zstats") OPTION(INPUT)"
    do forever
      'tbskip' rtll
      if rc > 3 then leave
      if zluser = resetid then iterate
      zluser = resetid
      'LMMSTATS DATAID('zstats') Member('mem') user('zluser')'
      'tbput' rtll
    end
    "LMClose Dataid("zstats")"
    ztdtop = save_top
    statfile = translate(strip(fulldsn,'B',"'"),' ','.')
    statfile = subword(statfile,qualignr+1)
    statfile = translate(statfile,'.',' ')
    statfile = localrep'/'zigirep'/.zigi/'statfile
    x = zigistat(fulldsn statfile 'S')
  end
  return

  /* ------------------------ *
  | Do the Commit Processing |
  * ------------------------ */
Do_Commit:
  zcmd = null
  parse value '' with msg1 msg2 msg3 msg4 msg5 msg6 msg7 msg8 msg9 ,
    msg10 msg11 msg12 msg13 msg14 msg15 msg16 msg17 zpush
  'display panel(zigicom)'
  if rc > 0 then do
    zerrsm = 'Cancelled.'
    zerrlm = 'Commit has been cancelled.'
    'setmsg msg(isrz003)'
  end
  else do
    cmessage = value('msg1')
    cmsg.1 = cmessage
    cmsg.2 = left('-',length(cmsg.1),'-')
    io = 2
    do ic = 2 to 17
      cmessage = value('msg'ic)
      cmessage = strip(cmessage)
      if cmessage /= null then do
        if cmessage = '.' then cmessage = '  '
        io = io + 1
        cmsg.io = cmessage
      end
    end
    cmsg.0 = io
    /* ------------------------------- *
    | If > 1 msg line then use a file |
    * ------------------------------- */
    if io > 2 then do
      file = 'cmsg'random(999)
      fdd  = file
      if sysvar('syspref') = null
      then filem = sysvar('sysuid')'.'file
      else filem = file
      file = localrep'/'zigirep'/'file
      file = "'"file"'"
      address tso
      'alloc f('fdd') new spa(1,1) tr recfm(f b) lrecl(72) blksize(0)',
        'ds('filem')'
      'execio * diskw' fdd '(finis stem cmsg.'
      'free  f('fdd')'
      call outtrap 'x.'
      'oput' filem file 'Text'
      'delete' filem
      call outtrap 'off'
      address ispexec
      cmd = 'cd' localrep'/'zigirep
      x = docmd(cmd '&& git commit -F' file)
    end
    /* ------------------------------------- *
    | If cmsg.0 = 2 then use commit -m msg   |
    * -------------------------------------- */
    else x = docmd(cmd "&& git commit -vm '"cmsg.1"'")
    call view_std 'B'
    /* ------------------------------- *
    | If > 1 msg then delete the msg  |
    | file from omvs                  |
    * ------------------------------- */
    if io > 1 then
    cmd = 'rm' file
    x = bpxwunix(cmd,,do.,de.)
    if zpush = 'Y' then call do_push 'x'
    call update_repo_metadata
  end
  return

  /* ---------------------------------- *
  | Push the updates to the remote git |
  * ---------------------------------- */
Do_Push:
  arg opt
  call pop 'Pushing Updates to Remote Git'
  cmd = 'cd' localdir' && git push -v'
  cmd = docmd(cmd)
  call view_std 'B'
  if opt = null then
  call update_repo_metadata
  return

  /* ----------------------------- *
  | Clone a remote repo           |
  * ----------------------------- */
Clone_Repo:
  parse value '' with localrep pdshlq remotebr
  do forever
    zcmd = null
    remote = null
    c_stat = 0
    cc_rc = 0
    'Display Panel(zigicc)'
    if rc > 0 then return
    if localrep = "?" then
    localrep = zigiosel()
    if strip(localrep) = null then do
      zerrsm = 'Cancelled.'
      zerrlm = 'Clone cancelled as OMVS directory selection cancelled.'
      'Setmsg msg(isrz003)'
      return
    end
    parse var remote site ':' user '/' zigirep '.git'
    parse var site guser '@' host
    /* Let's clone the remote repo... */
    zs1 = "Cloning "zigirep" by "user
    zs2 = "from "host
    call do_popup
    cmd = 'touch 'home'/.ssh/known_hosts && '
    cmd = cmd 'ssh-keyscan -t rsa,dsa 'host
    cmd = cmd ' 2>&1 | sort -u - 'home'/.ssh/known_hosts >'
    cmd = cmd ' 'home'/.ssh/tmp_hosts && '
    cmd = cmd 'mv 'home'/.ssh/tmp_hosts 'home'/.ssh/known_hosts'
    x = bpxwunix(cmd,,so.,se.)
    cmd = 'cd 'localrep
    if remotebr = null
    then cmd = cmd ' && git clone -v 'remote
    else cmd = cmd ' && git clone -vb' remotebr remote
    x = docmd(cmd)
    if x > 0 then do
      c_stat = 1
      call view_std 'B'
      Address ISPExec
      return
    end
    /* Check to see if this is a zigi-managed repo */
    cmd = '[[ ! -d 'localrep'/'zigirep'/.zigi ]] && echo 0'
    x = bpxwunix(cmd,,so.,se.)
    if so.0 = 1 & so.1 = 0 then do
      c_stat = 1
      x = bpxwunix('rm -rf 'localrep'/'zigirep,,so.,se.)
      Address ISPExec
      return
    end
    Address ISPExec
    if c_stat = 1 then return
    qualignr = words(translate(pdshlq,' ','.'))
    call Refresh localrep zigirep pdshlq qualignr
    zigikey = localrep'/'zigirep
    'tbadd zigirepo order'
    'TBSAVE zigirepo REPLCOPY LIBRARY('isptabl')'
    leave
  end
  call work_with_repo
  return

  /* ---------------------------------------- *
  | Process the selected dataset (PDS or PS) |
  * ---------------------------------------- */
Work_with_repo_file:
  x = listdsi(fulldsn)
  if sysdsorg /= 'PS' then do
    zs1 = 'Building list of library statuses....'
    zs2 = 'Patience . . .'
    call do_popup
  end
  /* Determine if the repo item is a PDS or a flat-file */
  if sysdsorg = 'PS' then do
    call edit_ps
  end
  else do
    /* Do this if it's a PDS */
    localdir = localrep'/'zigirep
    'TBCreate' rtll 'Keys(mem) Names(memstat ussmem zlcnorc' ,
      'zlmdate zlmtime zluser)',
      'replace NoWrite'
    address syscall
    'readdir 'localrep'/'zigirep'/'dsn' root.'
    address ispexec
    "LMINIT DATAID(DID) Dataset("fulldsn")"
    "LMOPEN DATAID("did")"
    cmd = 'cd' localrep'/'zigirep
    x = docmd(cmd '&& git status --porcelain')
    do i = 1 to root.0
      /* for all files but not . or .. */
      if root.i = "." | root.i = ".." then do
        iterate
      end
      else do
        mem = root.i
        memstat = null
        do ii = 1 to so.0
          /* see if we have this file in git status */
          stat = substr(so.ii,1,2)
          thepath = substr(so.ii,3)
          parse var thepath FOLDER "/" MEMBER
          if mem = MEMBER then do
            memstat = porcelain(stat)
            if FOLDER = "./" & stat = "??" then
            memstat = '[??] Untracked'
            leave
          end
        end
      end
      /* ------------------------------------------------------- *
      |  The files in OMVS have some chars changed due to cp -M |
      |  So we fix the name before we save to table :)          |
      * ------------------------------------------------------- */
      ussmem = mem
      mem = translate(mem,'#@$','._-')
      /* ---------------------------------------------- *
      | No get ISPF stats for each member for the list |
      * ---------------------------------------------- */
      "LMMFind DATAID("did") Member("mem") STATS(YES)"
      'tbadd' rtll
    end
    "LMCLOSE DATAID("did")"
    "LMFREE DATAID("did")"
    'tbsort' rtll 'Fields(mem,c,a)'
    'tbtop' rtll
    /* ---------------------------------- *
    | Process the Member list until done |
    * ---------------------------------- */
    save_top = 0
    ztdsels  = 0
    Do Forever
      parse value '' with zsel zcmd row
      if ztdsels = 0 then do
        'tbtop' rtll
        'tbskip' rtll 'number('save_top')'
        'TBdispl' rtll 'Panel(zigilist)'
      end
      else 'tbdispl' rtll
      if rc > 4 then do
        'tbend' rtll
        leave
      end
      /* Make sure we edit (and copy) right dataset when we have
      a prefix set */
      save_top = ztdtop
      edsn = strip(fulldsn,'B',"'")

      if row = 0 then zsel = null
      if row <> null then
      if row > 0 then do
        'TBTop' rtll
        'TBSkip' rtll 'Number('row')'
      end

      if zcmd /= null then
      Select
        When abbrev('GITHELP',zcmd,4) = 1 then
        Address TSO '%githelp'
        When abbrev('COMMIT',zcmd,3) = 1 then do
          zsel = null
          call do_commit
          call work_with_repo_file
        end
        When abbrev('GITLOG',zcmd,2) = 1 then call do_gitlog
        When abbrev('STATUS',zcmd,2) = 1 then call do_status
        When abbrev('RESET',zcmd,2) = 1 then call do_resetid
        When abbrev('SORT',word(zcmd,1),2) = 1 then call do_lsort
        When abbrev("L",translate(word(zcmd,1)),1) = 1 then do
          mem = translate(word(zcmd,2))
          'tbtop' rtll
          'tbsarg' rtll
          'tbscan' rtll 'arglist(mem) position(scanrow) condlist(ge)'
          if rc = 0 then do
            save_top = scanrow
            zerrsm = null
            zerrlm = word(zcmd,2) 'was found in row' ztdtop
            'Setmsg msg(isrz003)'
          end
          else do
            zerrsm = null
            zerrlm = word(zcmd,2) 'was not found'
            'Setmsg msg(isrz003)'
          end
        end
        Otherwise do
          zerrsm = 'Unknown'
          zerrlm = zcmd 'is not a recognized command.'
          'setmsg msg(isrz003)'
        end
        zsel = null
      end

      if zsel /= null then
      Select
        when zsel = 'S' then do
          /* -------------------------------- *
          | Edit PDS member or PS dataset    |
          * -------------------------------- */
          x = listdsi(fulldsn)
          edsn = strip(fulldsn,'B',"'")
          if sysdsorg = 'PS'
          then "Edit Dataset('"edsn"')"
          else "Edit Dataset('"edsn"("mem")'"
          if rc = 0 then do
            /* so after the edit, we should update it to repo */
            /* this is done via update_repo_metadata because  */
            /* now the user will not be ZIGI in ISPFSTATS     */
            /* this 'modifies' the fulldsn and dsn vars so    */
            /* better save before and restore after           */
            if ztdsels = 1 then do
              call update_repo_metadata
              /* then call this function again to update the    */
              /* status of the members in this pds after update */
              call work_with_repo_file
            end
          end
        end
        when zsel = 'A' then do
          /* -------------------------------- *
          | Add member of PDS to staging area|
          * -------------------------------- */
          d = usssafe(dsn)
          cmd = 'cd' localrep'/'zigirep'/'d
          /* These cp -M issues are really getting annoying */
          m = translate(mem,'._-','#@$')
          x = docmd(cmd || ' && git add -v 'm)
          /* save and then restore dsn and full dsn around
          update_repo_metadata  */
          if ztdsels = 1 then do
            statfile = translate(strip(fulldsn,'B',"'"),' ','.')
            statfile = subword(statfile,qualignr+1)
            statfile = translate(statfile,'.',' ')
            cmd = 'cd' localrep'/'zigirep'/.zigi/'
            cmd = cmd '&& git add -v 'statfile
            x = docmd(cmd)
            call update_repo_metadata
            /* then call this function again to update the    */
            /* status of the members in this pds after update */
            call work_with_repo_file
          end
        end
        when zsel = 'U' then do
          /* -------------------------------- *
          | Undo a commit. eg checkout --    |
          * -------------------------------- */
          d = usssafe(dsn)
          cmd = 'cd' localrep'/'zigirep'/'d
          /* These cp -M issues are really getting annoying */
          m = translate(mem,'#@$','._-')
          m = translate(mem,'._-','#@$')

          zs1 = 'Un-modiying 'mem
          zs2 = 'This never happened...'
          call do_popup
          address 'SYSCALL' 'SLEEP (1)'
          x = docmd(cmd || ' && git checkout -- 'm)
          /* after the checkout --, we better re-populate   */
          /* the z/OS datasets                              */
          call Refresh localrep zigirep pdshlq qualignr
          call update_repo_metadata
          /* then call this function again to update the    */
          /* status of the members in this pds after update */
          call work_with_repo_file
        end
        when zsel = 'D' then do
          /* -------------------------------- *
          | Show the diff for the member     |
          * -------------------------------- */
          d = usssafe(dsn)
          cmd = 'cd' localrep'/'zigirep'/'d
          /* These cp -M issues are really getting annoying */
          m = translate(mem,'#@$','._-')
          x = docmd(cmd ' && git diff 'm)
          if so.0 + se.0 > 0
          then call View_std
          else do
            zerrsm = 'No Diff'
            zerrlm = 'No differnce found.'
            'Setmsg msg(isrz003)'
          end
        end
        otherwise nop
      end
    end
  end
  return

  /* ------------------------- *
  | Copy a PS dataset to OMVS |
  * ------------------------- */
Edit_PS:
  arg noedit
  edsn = strip(fulldsn,'B',"'")
  if noedit = null then do
    /* Do this if it's a regular file (sequential in z/OS) */
    "Edit Dataset('"edsn"')"
    /* so after the edit, we should update it to working directory */
  end
  else rc = 0
  if rc = 0 then do
    edsn = usssafe(edsn)
    copcm = "//'"edsn"'"
    copcm = 'cp -U -M "'copcm'" 'localrep'/'zigirep'/'dsn
    x = bpxwunix(copcm,,so.,se.)
    call view_std 'B'
  end
  call update_repo_metadata
  return

/* ------------------------------- *
 | Sort the member list (zigilist) |
 * ------------------------------- */
Do_LSort:
  parse value zcmd with x sort_field sort_order sf sc
  if sort_field = null then do
    call pfshow 'off'           /* make sure pfshow is off */
    'Addpop row(4) column(6)'
    'Display Panel(zigilsrt)'
    'Rempop'
    sort_field = sf
    sort_order = sc
    call pfshow 'reset'         /* restore pfshow setting */
  end
  if sort_order = null then sort_order = 'A'
  /* support abbreviations in field names */
  Select
    When abbrev('MEMBER',sort_field,2) = 1 then sort_field = 'MEMBER'
    When abbrev('STATUS',sort_field,2) = 1 then sort_field = 'STATUS'
    When abbrev('SIZE',sort_field,2)   = 1 then sort_field = 'SIZE'
    When abbrev('DATE',sort_field,2)   = 1 then sort_field = 'DATE'
    When abbrev('TIME',sort_field,2)   = 1 then sort_field = 'TIME'
    When abbrev('USERID',sort_field,2) = 1 then sort_field = 'USERID'
    Otherwise nop
  end
  /* 1st validate sort_field */
  if wordpos(sort_field,'MEMBER STATUS SIZE DATE TIME USERID') = 0
  then do
    zerrsm = 'Invalid.'
    zerrlm = sort_field 'is an invalid sort field. Valid names are:' ,
      'MEMBER STATUS SIZE DATE TIME USERID'
    'Setmsg msg(isrz003)'
    return
  end
  /* 2nd validate the sort_order A or D */
  if pos(sort_order,'AD') = 0 then do
    zerrsm = 'Invalid.'
    zerrlm = sort_order 'is an invalid sort order. Must be either' ,
      'A for ascending or D for descending.'
    'Setmsg msg(isrz003)'
    return
  end
  sw = wordpos(sort_field,'MEMBER STATUS SIZE DATE TIME USERID')
  sort_field = subword('mem memstat zlcnorc zlmdate zlmtime zluser',sw,1)
  if sw = 3 then sort_type = 'N'
  else sort_type = 'C'
  'tbsort' rtll 'fields('sort_field','sort_type','sort_order')'
  return

  /* ----------------------------- *
  | Refresh z/OS side of repo     |
  * ----------------------------- */
Refresh:
  parse arg localrep zigirep pdshlq qualignr .
  zs1 = "Refreshing from repository"
  zs2 = "   OMVS -> z/OS      "
  call do_popup
  address 'SYSCALL' 'SLEEP (2)'
  x = docmd('cd 'localrep' && git clone 'remote)
  ckotdir = localrep'/'zigirep
  if datatype(qualignr) /= 'NUM' then qualignr = 0
  if qualignr = 0
  then ckothlq = pdshlq
  else do
    ckothlq = translate(pdshlq,' ','.')
    ckothlq = subword(ckothlq,1,qualignr)
    ckothlq = translate(ckothlq,'.',' ')
  end
  'vput (ckotdir ckothlq)'
  'Select cmd(%zigickot)'
  return

  /* ----------------------------- *
  | Branch management             |
  * ----------------------------- */
Branch_it:
  'tbquery' rtbb
  if rc = 0 then 'tbend' rtbb
  'TBCreate' rtbb 'keys(bname) Names(brstatus) Replace NoWrite'
  localdir = localrep'/'zigirep
  cmd = ' && git remote prune origin > /dev/null 2>&1 && git branch -a'
  x = docmd('cd 'localdir cmd)
  if so.0 + se.0 = 0 then do
    cmd = '&& git branch -a'
    x = docmd('cd 'localdir cmd)
  end
  bl. = null
  bl.0 = 0
  do i = 1 to so.0
    b1 = strip(so.i,'B')
    if pos('/',b1) > 0 then do
      /* this is a remote branch we (maybe) have never checked out */
      seen_this_branch = 0
      parse var b1 remotes'/'origin'/'bname zooi
      bname = strip(bname)
      do ii = 1 to bl.0
        if bl.ii = bname then seen_this_branch = 1
      end
      if seen_this_branch = 1 then do
        sbname = bname
        'tbtop' rtbb
        do forever
          'tbskip' rtbb
          if rc > 0 then leave
          if sbname = bname then do
            brstatus = 'Local/Remote'
            'tbmod' rtbb
            leave
          end
        end
      end
      /* but only add it to table if we haven't yet */
      if seen_this_branch = 0 then do
        if bname <> branch & bname <> "HEAD" then do
          ni = bl.0 + 1
          bl.ni = bname
          bl.0 = ni
          brstatus = 'Remote'
          'tbadd' rtbb
        end
      end
    end
    else do
      /* this is already a local branch */
      if pos('*',b1) = 0 then do
        /* Add it to the table if it's not the current (*) branch */
        bname = strip(so.i)
        ni = bl.0 + 1
        bl.ni = b1
        bl.0 = ni
        brstatus = 'Local'
        'tbadd' rtbb
      end
    end
  end
  'tbsort' rtbb 'fields(bname,c,a)'
  'tbtop' rtbb
  save_btop = 0
  do forever
    zcmd = null
    cc_rc = 0
    newb = null
    zsel = null
    if save_btop > 0 then do
      'tbtop' rtbb
      'tbskip' rtbb 'number('save_btop')'
    end
    'tbdispl' rtbb 'panel(zigibra)'
    if rc > 4 then leave
    save_btop = ztdtop
    if abbrev('GITHELP',zcmd,4) = 1 then
    Address TSO '%githelp'
    if newb <> null then do
      /* ----------------------------- *
      | Create this new branch, switch|
      * ----------------------------- */
      localdir = localrep'/'zigirep
      x = docmd('cd 'localdir' && git checkout -b 'newb)
      cmd = docmd('cd 'localdir' && git push -u origin 'newb)
      branch = newb
      leave
    end
    /* ----------------------------- *
    | Checkout the selected bname   |
    * ----------------------------- */
    if zsel = "C" then do
      x = docmd('cd 'localdir' && git status --porcelain')
      if so.0 > 0 then do
        zs1 = 'Cannot checkout branch.'
        zs2 = so.1
        call pfshow 'off'           /* make sure pfshow is off */
        'Addpop row(4) column(12)'
        'Display Panel(zigipop)'
        'Rempop'
        call pfshow 'reset'         /* restore pfshow setting */
        call view_std 'B'
      end
      x = docmd('cd 'localdir' && git checkout 'bname)
      call update_repo_metadata
      call Refresh localrep zigirep pdshlq qualignr
      branch = bname
      leave
    end
    if zsel = "D" then do
      x = docmd('cd 'localdir' && git branch -D 'bname)
      'tbdelete' rtbb
      zerrsm = 'Deleted.'
      zerrlm = 'Branch 'bname' succesfully deleted'
      'Setmsg msg(isrz003)'
    end
  end
  'tbend' rtbb
  ztdsels = 0
  return

Create_Repo:
  do forever
    parse value '' with zerrsm zcmd zigirep cc_rc pdshlq localrep
    'Display Panel(ziginew)'
    if rc > 0 then return 8
    if localrep = '?' then
    localrep = zigiosel()
    /* ---------------------------------------------------- *
    | We do some basic git repo setup here...              |
    | Fair warning, it's going to be very verbose.         |
    | But that eases feature adding :)                     |
    * ---------------------------------------------------- */
    /* test if localrep is present */
    cmd = '[[ -d 'localrep' ]] && echo 1'
    x = bpxwunix(cmd,,so.,se.)
    if so.0 = 1 & so.1 = 1 then do
      /* ok, localrep is there. better not have zigirep */
      cmd = '[[ -d 'localrep'/'zigirep' ]] && echo 1'
      x = bpxwunix(cmd,,so.,se.)
      if so.0 = 1 & so.1 = 1 then do
        zerrsm = "Failed."
        zerrlm = "Error: "localrep"/"zigirep" exists and must not."
        'setmsg msg(isrz003)'
        leave
      end
    end
    /* If we made it here, we can freely git init */
    zs1 = 'Creating your repository'
    zs2 = 'Please standby'
    call do_popup
    x = docmd('cd 'localrep' && git init 'zigirep)
    /* The git repo is initialized. Time to stick a
    .gitattributes (ASCII) in there */
    call syscalls 'ON'
    address syscall
    path = localrep"/"zigirep"/.ga"
    'open' path,
      O_rdwr+O_creat+O_trunc,
      660
    if retval = -1 then do
      Address ISPExec
      zs1 = "Something bad when creating .gitattributes. Make errormsg"
      zs4 = 'Press F3 to close this popup and exit.'
      parse value '' with zs2 zs3
      call do_popup4
      leave
    end
    fd = retval  /* as I think it's weird to write to a retval lol */
    call write_fd ,
      "# This .gitattributes file is autogenerated with zigi v1r0"
    call write_fd ,
      "*   git-encoding=iso8859-1 zos-working-tree-encoding=ibm-1047"
    ga3a = ".gitattributes    "
    ga3b = "git-encoding=iso8859-1 zos-working-tree-encoding=iso8859-1"
    ga3  = ga3a || ga3b
    call write_fd ga3
    ga4a = ".gitignore        "
    ga4b = "git-encoding=iso8859-1 zos-working-tree-encoding=iso8859-1"
    ga4  = ga4a || ga4b
    call write_fd  ga4
    'close' fd
    /* -------------------- .gitattributes written ----------- */
    /*             UNFORTUNATELY, IT'S IN EBCDIC :(            */
    /* ------------------------------------------------------- */
    reporoot = localrep'/'zigirep'/'
    /* convert to iso8859-1 */
    cmd = 'cd 'localrep'/'zigirep' && '
    cmd = cmd 'iconv -f ibm-1047 -t iso8859-1 .ga'
    cmd = cmd ' > .gitattributes'
    x = bpxwunix(cmd,,so.,se.)

    /* delete the .ga file */
    cmd = 'cd 'localrep'/'zigirep' && rm -rf .ga'
    x = bpxwunix(cmd,,so.,se.)

    /* tag it and bag it */
    cmd = 'cd 'localrep'/'zigirep' && '
    cmd = cmd 'chtag -tc iso8859-1 .gitattributes'
    x = bpxwunix(cmd,,so.,se.)

    /* Create the .zigi folder in the repo and add the dsn-file */
    cmd = 'cd 'localrep'/'zigirep' && mkdir .zigi'
    x = bpxwunix(cmd,,so.se.)

    /* Fill dsn file with the comments */
    path = localrep"/"zigirep"/.zigi/dsn"
    'open' path,
      O_rdwr+O_creat+O_trunc,
      660
    if retval = -1 then do
      Address ISPExec
      zs1 = "Something bad when creating .zigi/dsn."
      zs4 = 'Press F3 to close this popup and exit.'
      parse value '' with zs2 zs3
      call do_popup4
      leave
    end
    fd = retval  /* as I think it's weird to write to a retval lol */
    call write_fd "# zigi" ver "dsn-file "
    call write_fd "# This file needs to be here."
    call write_fd "# Don't edit unless you know what you're doing :)"
    call write_fd '#  '
    call write_fd '# record format is (case insensitive):'
    call write_fd '#  '
    call write_fd '# Position - description'
    call write_fd '#  '
    call write_fd '# 1 - directory name which will be prefixed by the'
    call write_fd '#     defined HLQ to create the z/OS dataset'
    call write_fd '#     (* defines the default)'
    call write_fd '# 2 - PS or PO (dataset organization)'
    call write_fd '#     PS for a flat file'
    call write_fd '#     PO for a directory and thus a partitioned dataset'
    call write_fd '# 3 - record format (FB or VB)'
    call write_fd '# 4 - lrecl'
    call write_fd '# 5 - blksize'
    call write_fd '#     0 is allowed if system determined blksize is enabled'
    call write_fd '#  '
    call write_fd '# Default DSORG and DCB info'
    call write_fd '* PO FB 80 32720'
    'close' fd

    /* ------------------ Let's make our first commit :)       */
    x = docmd('cd 'reporoot' && git add .gitattributes')

    x = docmd('cd 'reporoot' && git add .zigi/dsn')

    commitmsg = "added by zigi v1r1"
    x = docmd('cd 'reporoot' && git commit -m "'commitmsg'"')

    Address ISPExec
    zigikey = localrep'/'zigirep
    'tbadd zigirepo order'
    'TBSAVE zigirepo REPLCOPY LIBRARY('isptabl')'
    leave
  end
  return 0

  /* ---------------------------------------------------------- *
  | Generalized routine to view stdout. (so.) or stderr. (se.) |
  | based on the parm passed                                   |
  * ---------------------------------------------------------- */
view_std:
  arg stdopt
  'Control Display Save'
  /* ------------------------------- *
  | Randomly define a DDName to use |
  * ------------------------------- */
  dd = 'dd'random(9999)
  /* --------------------------------------- *
  | Get lrecl to determine dcb for temp d/s |
  * --------------------------------------- */
  vlrecl = 0
  do li  = 1 to so.0
    if length(so.li) > vlrecl then vlrecl = length(so.li)
  end
  do li  = 1 to se.0
    if length(se.li) > vlrecl then vlrecl = length(se.li)
  end
  if vlrecl < 81 then vlrecl = 80
  /* ------------------------------------------ *
  | Allocate a temporary data set for our data |
  * ------------------------------------------ */
  Address TSO
  'Alloc f('dd') new spa(5,5) tr' ,
    'recfm(v b) lrecl('vlrecl+4') blksize(0)'
  /* ------------------------------- *
  | Replace null records with blank |
  * ------------------------------- */
  do xi = 1 to so.0
    if so.xi = null
    then so.xi = ' '
  end
  do xi = 1 to se.0
    if se.xi = null
    then se.xi = ' '
  end
  sec = so.0 + se.0
  /* ----------------------------- *
  | If stdopt is 'B' then do both |
  * ----------------------------- */
  stdopt = null
  sc = so.0
  do xi = 1 to se.0
    sc = sc + 1
    so.sc = se.xi
  end
  so.0 = sc
  drop se.
  /* ----------------------- *
  | Write out the stem data |
  * ----------------------- */
  if stdopt = null
  then do
    'Execio * diskw' dd '(finis stem so.'
    drop so.
  end
  else do
    'Execio * diskw' dd '(finis stem se.'
    drop se.
  end
  /* -------------------------------------------------- *
  | Access the Temporary Data Set using ISPF           |
  | Library Services.                                  |
  | Then using ISPF Browse service to browse the data. |
  | And use Library Services to Free the Data Set.     |
  * -------------------------------------------------- */
  Address ISPExec
  if sec > 0 then do
    'lminit dataid(ddb) ddname('dd')'
    'browse dataid('ddb') panel(zigibrow)'
    'lmfree dataid('ddb')'
  end
  /* ----------------------------- *
  | Last Free the z/OS Allocation |
  * ----------------------------- */
  Address TSO ,
    'Free f('dd')'
  'Control Display Restore'
  return


  /* -------------------------------------------------------- *
  | This routine will generate the users personal SSH Public |
  | Key.                                                     |
  * -------------------------------------------------------- */
Build_SSH:
  parse value '' with zigissh
  zs1 = 'Building SSH Key'
  zs2 = 'Patience . . .'
  do forever
    call do_popup
    call catsshk
    if zigissh /= null then leave
  end
  return

  /* ------------------------------ *
  | Cat the current ssh key if any |
  * ------------------------------ */
catsshk:
  drop so. se.
  cmd = 'cat' keyfile
  x = bpxwunix(cmd,,so.,se.)
  if se.0 = 0
  then do
    zigissh = so.1
    'vput (zigissh) profile'
  end
  else zigissh = null
  return


  /* -------------------------- *
  | Lowercase the input string |
  * -------------------------- */
Lower:
  parse arg input
  out = translate(input,"abcdefghijklmnopqrstuvwxyz",,
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  return out

Upper:
  parse arg input
  OUT = TRANSLATE(input,"ABCDEFGHIJKLMNOPQRSTUVWXYZ",,
    "abcdefghijklmnopqrstuvwxyz")
  return out

dsnvalid: Procedure
  /* Tests for a 'potentially valid' z/OS datasetname */
  parse arg val_dsn
  upp = TRANSLATE(val_dsn,".ABCDEFGHIJKLMNOPQRSTUVWXYZ",,
    ".abcdefghijklmnopqrstuvwxyz")
  if upp = val_dsn then do
    call outtrap 'x.'
    if sysdsn(val_dsn) = "OK" | sysdsn(val_dsn) = "DATASET NOT FOUND" then do
      call outtrap 'off'
      return "OK"
    end
    call outtrap 'off'
  end
  else do
    return "NO"
  end

  /* ------------------------------------------------- *
  |                                                  |
  | String replace routine                           |
  | input string                                     |
  | from string                                      |
  | to string                                        |
  | translate is input to from                       |
  * ------------------------------------------------- */
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

idle:
  parse arg secs
  if secs = null | secs = null then secs=1
  x = docmd('sleepnd -v git')
  return

update_repo_metadata:
  save_fulldsn = fulldsn
  save_dsn = dsn
  x = debug('start of update_repo_metadata')
  if rtbl_open = 1 then do
    'tbend' rtbl
    rtbl_open = 0
    ztdsels = 0
    rtop = 0
  end
  if rtbl_open = 0 then
  'TBCreate' rtbl 'Keys(fulldsn) Names(dsnstat dsn pdshlq) Replace NoWrite'
  rtbl_open = 1
  /* We always fetch when we start to work on a repo */
  x = debug('fetching remote')
  zs1 = 'Fetching Remote info'
  zs2 = 'Patience . . .'
  call do_popup
  /* get the remote info.....but */
  /* we have to get rid of the tab in git output */
  x = debug('getting the remotes')
  gitcmd = 'git remote -v | sed -e "s/[[:space:]]\+/ /g"'
  localdir = localrep'/'zigirep
  x = docmd('cd 'localdir' && 'gitcmd)
  if so.0 > 0 then
  remote1 = word(so.1,1) ' ' word(so.1,2)
  if so.0 = 0 then do
    remote1 = "<no remote defined>"
    remote2 = null
  end
  cmd = 'cd' localrep'/'zigirep
  /* Fetch only if there's a remote */
  if remote1 /= '<no remote defined>' then
  x = docmd(cmd '&& git fetch')
  x = debug('...done')
  /* now we get the status for all in the repo */
  if se.0 > 1 then fetchmsg = "Remote updates, check status"
  else fetchmsg = "No remote updates"
  zs1 = 'Updating Repo and/or Getting Stats'
  zs2 = 'Patience . . .'
  call do_popup
  /* get all the files that are in the repo */
  x = debug('getting all files in repo-1')
  address syscall
  'readdir 'localrep'/'zigirep' root.'
  address ispexec
  x = debug('...done')
  x = debug('iterating...')
  do i = 1 to root.0
    if root.i = "." | root.i = ".." then do
      iterate
    end
    else do
      /* not the . and .. things */
      if dsnvalid("'"root.i"'") = "OK" then do
        /* and only for valid z/OS-datasets (skip README.md et al) */
        r = usssafe(root.i)
        x = debug('   check file or dir')
        cmd = '[ -d 'localrep'/'zigirep'/'r' ] && echo "DIR"'
        so.1 = null
        x = bpxwunix(cmd,,so.,se.)
        x = debug('   done')
        if qualignr = 0 then do
          if pdshlq /= '' then
          fulldsn = "'"pdshlq"."root.i"'"
          else
          fulldsn = "'"root.i"'"
        end
        else do
          fulldsn = translate(pdshlq,' ','.')
          fulldsn = subword(fulldsn,1,qualignr)
          fulldsn = translate(fulldsn,'.',' ')
          fulldsn = "'"fulldsn'.'root.i"'"
        end
        edsn = strip(fulldsn,'B',"'")
        if so.1 = "DIR" & x = 0 then do
          x = debug('its a dir...lmmstat all the things')
          Address TSO
          statfile = localrep'/'zigirep'/.zigi/'root.i
          mem_delta = zigistat("'"edsn"'" statfile 'C')
          Address ISPExec
          mem_hit = 0
          do im = 1 to words(mem_delta)
            mem = word(mem_delta,im)
            m = strip(mem)
            m = usssafe(m)
            e = usssafe(edsn)
            r = usssafe(root.i)
            /* TODO? Use Scottish Command here ? */
            copycmd = "//'"e"("m")'"
            copycmd = '"'copycmd'"'
            copycmd = "cp -U -M" copycmd" "localrep"/"zigirep
            copycmd = copycmd || "/"r"/"
            call bpxwunix copycmd
            mem_hit = 1
          end
          if mem_hit = 1 then
          x = zigistat("'"edsn"'" statfile 'S')
        end
        else do
          /* It must be a PS, just copy it over to OMVS */
          s = usssafe(fulldsn)
          copycmd = "//"s
          copycmd = '"'copycmd'"'
          copycmd = "cp -U -M" copycmd" "localrep"/"zigirep"/"root.i
          x = bpxwunix(copycmd,,co.,ce.)
        end
      end
    end
  end

  zs1 = 'Building List of repository Data Sets'
  zs2 = fetchmsg
  call do_popup
  x = debug('get the status')
  cmd = 'cd' localrep'/'zigirep
  x = docmd(cmd '&& git status --porcelain')
  x = debug('done')
  /* get the stuff from the repo-file */
  x = debug('get all the files (again?)')
  address syscall
  'readdir 'localrep'/'zigirep' root.'
  address ispexec
  x = debug('done')
  x = debug('iterate the files')
  do i = 1 to root.0
    dsnstat = null
    if root.i = "." | root.i = ".." then do
      iterate
    end
    else do
      if dsnvalid(root.i) = "OK" then do
        x = debug('Get the git status and fill dsnstat')
        dsn = root.i
        do ii = 1 to so.0
          stat = substr(so.ii,1,2)
          PATH = substr(so.ii,4)
          if pos(dsn, PATH) = 1 then do
            dsnstat = porcelain(stat)
            leave
          end
        end
        x = debug('done')

        if qualignr = null then do
          qualignr = 0
          'tbmod zigirepo'
        end
        if qualignr = 0 then do
          if pdshlq /= '' then
          fulldsn = "'"pdshlq"."dsn"'"
          else
          fulldsn = "'"dsn"'"
        end
        else do
          fulldsn = translate(pdshlq,' ','.')
          fulldsn = subword(fulldsn,1,qualignr)
          fulldsn = translate(fulldsn,'.',' ')
          fulldsn = "'"fulldsn'.'dsn"'"
        end
        if sysdsn(fulldsn) /= ok then dsnstat = 'Missing z/OS Dataset'
        'tbadd' rtbl
      end
    end
  end

  /* --------------------------- *
  | Get the current branch info |
  * --------------------------- */
  x = debug('getting git status for branch names')
  x = docmd('cd 'localdir' && git status')
  branch = word(so.1,3)
  if so.0 > 1 then do
    branch_status = word(so.2,4)
    parse var so.2 bstat","baction
  end
  else do
    parse value '' with branch_status bstat baction
  end
  'tbsort' rtbl 'fields(fulldsn)'
  fulldsn = save_fulldsn
  dsn = save_dsn
  return

porcelain:
  parse arg status

  /* parse git status --short as documented in
  https://www.git-scm.com/docs/git-status#_short_format */

  Select
    When stat == " M" then res = "Modified"
    When stat == " D" then res = "Deleted"
    When stat == " R" then res = "Renamed"
    When stat == " C" then res = "Copied"
    When stat == "M " then res = "Ready to commit"
    When left(stat,1) == " " then res = "Not Updated"
    When left(stat,1) == "M" then res = "Updated in index"
    When left(stat,1) == "A" then res = "Added to index"
    When left(stat,1) == "D" then res = "Deleted from index"
    When left(stat,1) == "R" then res = "Renamed in index"
    When left(stat,1) == "C" then res = "Copied in index"
    When stat == "??" then res = "Untracked"
    When stat == "MM" then res = "Modified"
    When stat == "AM" then res = "Modified"
    When stat == "RM" then res = "Modified"
    When stat == "CM" then res = "Modified"
    When stat == "MD" then res = "Deleted"
    When stat == "AD" then res = "Deleted"
    When stat == "RD" then res = "Deleted"
    When stat == "CD" then res = "Deleted"
    When stat == "DR" then res = "Renamed"
    When stat == "DC" then res = "Copied"
    When stat == "??" then res = "Untracked"
    When stat == "!!" then res = "Ignored"
    Otherwise res = null
  end
  return '[' || status || '] ' || res

usssafe: procedure
  parse arg dsn
  if pos('$',dsn) = 0 then return dsn
  dsn = strreplace(dsn, '$', '\$')
  return dsn

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

  /* ------------------------------- *
  | Add a dataset to the repository |
  * ------------------------------- */
Add_Dataset:
  parse value '' with zcmd what list dsnapfx zsel
  dsnapfx = pdshlq
  lc_count = 0
  add_count = 0
  top = 0
  dsnatbl = 'ZIGID'random(999)
  call tbcreate_dsnatbl
  if dsnapfx = null then qualignr = null
  do forever
    parse value '' with zsel zcmd row
    'tbquery' rtbl 'rownum(rows)'
    if rows = 0
    then dsnapnl = 'zigidsna'
    else do
      dsnapnl = 'zigidsnb'
      if list /= 1 then
      call get_list
    end
    if ztdsels > 1
    then 'tbdispl' dsnatbl
    else do
      select
        when add_count = 0 & list = 1 then csr = 'ZSEL'
        when dsnapfx  = null then csr = 'DSNAPFX'
        when qualignr = null then csr = 'QUALIGNR'
        otherwise csr = 'ZCMD'
      end
      'tbtop' dsnatbl
      'tbskip' dsnatbl 'number('top')'
      'tbdispl' dsnatbl 'panel('dsnapnl') cursor('csr')'
    end
    if add_count > 0 then
    if qualignr = 0 then
    pdshlq = ''
    else pdshlq  = dsnapfx
    if rc > 4 then do
      zsel = null
      'tbput' rtbl
      'tbend' dsnatbl
      'tbsort' rtbl 'fields(fulldsn,c,a)'
      'tbtop' rtbl
      if add_count > 0 then
      'tbmod zigirepo'
      'TBSAVE zigirepo REPLCOPY LIBRARY('isptabl')'
      return
    end
    top = ztdtop
    if row = 0 then zsel = null
    if row <> null then
    if row > 0 then do
      'TBTop' dsnatbl
      'TBSkip' dsnatbl 'Number('row')'
    end

    if zsel = 'B' then do
      'control display save'
      "LMInit Dataid(edvbr) dataset('"dsna"')"
      "Memlist Dataid("edvbr") Default(B)"
      "LMfree Dataid("edvbr")"
      'control display restore'
    end
    if zsel = 'S' | zsel = 'A' then do
      call do_add_copy
    end

    if list = null then call get_list
    if lc_count = 0 then do
      zerrsm = 'Empty List'
      zerrlm = 'The requested high level qualifier resulted in zero' ,
        'eligible datasets.'
      'setmsg msg(isrz003)'
    end
    'tbtop' dsnatbl
  end
  return

tbcreate_dsnatbl:
  'tbcreate' dsnatbl 'keys(dsna) names(dastat) nowrite'
  return

Get_List:
  'tbend' dsnatbl
  call tbcreate_dsnatbl
  dsnapfx = strip(dsnapfx)
  cmd = 'ls' localrep'/'zigirep
  x = bpxwunix(cmd,,so.,se.)
  Address TSO
  call outtrap 'x.'
  'listc level('dsnapfx')'
  call outtrap 'off'
  Address ISPExec
  do dsni = 1 to x.0
    if left(x.dsni,7) /= 'NONVSAM' then iterate
    parse value x.dsni with . . dsna .
    dastat = null
    do gl = 1 to so.0
      if right(dsna,length(word(so.gl,1))) = word(so.gl,1)
      then dastat = 'Added'
    end
    'tbadd' dsnatbl
    lc_count = lc_count + 1
  end
  list = 1
  return

  /* -------------------------------------------- *
  | Perform the actual copy of the added dataset |
  | to the local repository.                     |
  * -------------------------------------------- */
Do_Add_Copy:
  zsel = null
  what = dsna
  if qualignr >= 0
  then do
    dsnb = translate(dsna,' ','.')
    dsnb = subword(dsnb,qualignr+1)
    dsnb = translate(dsnb,'.',' ')
  end
  zs1 = 'Copying' dsna
  zs2 = 'to' dsnb 'in OMVS'
  zs3 = ' '
  zs4 = 'Patience . . .'
  call do_popup4
  DIR = localrep'/'zigirep
  FC = LISTDSI("'"WHAT"'")
  if sysrecfm = 'U' then do
    if ztdsels = 1 then do
      zerrsm = 'Invalid'
      zerrlm = 'Dataset' what 'is not a valid Git dataset. Must be' ,
        'RECFM of Fixed or Variable and not U.'
      'Setmsg msg(isrz003)'
    end
    dastat = 'Invalid Recfm'
    'tbmod' dsnatbl
    return
  end
  if SYSDSORG = 'PO' then do
    pds = what
    PDS = strip(PDS,"B","'")
    pdss = usssafe(dsnb)
    pdsc = usssafe(pds)
    mkdir = "mkdir -p "DIR"/"pdss
    x = bpxwunix(mkdir,,so.,se.)
    copycmd = "//'"pdsc"'"
    copycmd = '"'copycmd'"'
    copycmd = "cp -U -M" copycmd" "DIR"/"pdss"/"
    x =bpxwunix(copycmd,,so.,se.)
    Address TSO '%zigistat' "'"pds"'" dir"/.zigi/"dsnb 'S'
    x = docmd('cd' dir '&& git add .zigi/'pdss)
  end
  else do
    W = usssafe(WHAT)
    PSS = usssafe(dsnb)
    copycmd = "//'"W"'"
    copycmd = '"'copycmd'"'
    copycmd = "cp -U -M" copycmd" "DIR"/"pss
    call bpxwunix copycmd
  end
  dsnstat = '[??] Untracked'
  dsn = dsnb
  fulldsn = "'"what"'"
  pdshlq = dsnapfx
  'tbadd' rtbl
  dastat = 'Added'
  'tbmod' dsnatbl
  add_count = add_count + 1
  call save_dsninfo
  return

  /* ------------------------------------------------------- *
  | Get the DCB and optionally Directory info for the added |
  | dataset and save in the /.zigi/dsn file for use when    |
  | creating/recreating the z/OS dataset.                   |
  |                                                         |
  | Routine uses OGET and OPUT along with ALLOC/EXECIO.     |
  |                                                         |
  | Format is:                                              |
  | dsn PS/PO recfm lrecl blksize                           |
  * ------------------------------------------------------- */
Save_dsninfo:
  x = listdsi(fulldsn)
  dsn_record = dsn sysdsorg sysrecfm syslrecl sysblksize
  if sysvar('syspref') = null then pref = sysvar('sysuid')'.'
  else pref = null
  sd_dsn = pref'zigi.t'time('s')
  sd_dd  = 'zdd'time('s')
  path = localrep"/"zigirep"/.zigi/dsn"
  address tso
  call outtrap 'x.'
  "oget '"path"'" sd_dsn 'text'
  'alloc f('sd_dd') shr ds('sd_dsn')'
  'execio * diskr' sd_dd '(finis stem sd.'
  do x = 1 to sd.0
    if word(sd.x,1) = dsn then do
      'free f('sd_dd')'
      'delete' sd_dsn
      call outtrap 'off'
      Address ISPExec
      return
    end
  end
  slast = sd.0
  slast = slast + 1
  sd.slast = dsn_record
  sd.0 = slast
  do sx = 1 to sd.0
    sd.sx = translate(sd.sx,' ','0D'x)
  end
  'execio * diskw' sd_dd '(finis stem sd.'
  call outtrap 'x.'
  'oput' sd_dsn "'"path"' text"
  'free f('sd_dd')'
  'delete' sd_dsn
  cmd = 'cd 'localrep'/'zigirep' && git add .zigi/dsn'
  cmd = cmd ' && git commit -m "zigi dsn update"'
  x = docmd(cmd)
  call outtrap 'off'
  Address ISPExec
  return

Write_FD:
  parse arg string
  string = string || ESC_R || ESC_N
  'write' fd 'string' length(string)
  return

  /* ----------------------- *
  | Generalized Pop Message |
  | with msg passed         |
  * ----------------------- */
Pop:
  parse arg zs1 zs2
  add = address()             /* save addressing environment */
  Address ISPExec
  call do_popup
  Address add                 /* restore addressing environment */
  return

  /* ---------------------------------------- *
  | Common routine for normal (2 line) popup |
  * ---------------------------------------- */
Do_Popup:
  call pfshow 'off'           /* make sure pfshow is off */
  'Control Display Lock'
  'Addpop row(4) column(12)'
  'Display Panel(zigipop)'
  'Rempop'
  call pfshow 'reset'         /* restore pfshow setting */
  return

  /* ---------------------------------------- *
  | Common routine for normal (4 line) popup |
  * ---------------------------------------- */
Do_Popup4:
  call pfshow 'off'           /* make sure pfshow is off */
  'Control Display Lock'
  'Addpop row(4) column(6)'
  'Display Panel(zigipop4)'
  'Rempop'
  call pfshow 'reset'         /* restore pfshow setting */
  return

  /* ----------------------------------------------------- *
  | Get the users current OMVS enviornment for use in the |
  | bpxwunix commands.                                    |
  * ----------------------------------------------------- */
GETENV:
  x = debug('Starting collection of env variables')
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
  x = debug('Finished collection of env variables')
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

debug:
  if zigidebg  = 1 then do
    parse arg msg
    msg = Date() Time()' : 'msg
    c = 'echo "'msg'" >> 'home'/zigidebug.txt'
    x = bpxwunix(c,,so.,se.)
    if so.0 + se.0 > 0 then
    call view_std 'B'
    zigidebg_use = 1
  end
  return 0
