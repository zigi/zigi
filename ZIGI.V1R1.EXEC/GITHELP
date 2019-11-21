  /*%NOcomment ----------  rexx procedure  -------------------- *
  | Name:      GitHelp                                         |
  |                                                            |
  | Function:  Display a menu (table) of git commands and      |
  |            allow the user to view the selected help,       |
  |            filtering using Only xxx and a Refresh          |
  |            options are provided.                           |
  |                                                            |
  | Syntax:   %Githelp                                         |
  |                                                            |
  | Usage Notes:                                               |
  |       1. git must be installed on the local OMVS           |
  |          environment                                       |
  |       2. The user must have OMVS capabilities              |
  |                                                            |
  | Author:    Lionel B. Dyck                                  |
  |                                                            |
  | History:  (most recent on top)                             |
  |            11/21/19 LBD - Test after Only for 0 rows       |
  |            11/20/19 LBD - Enable a wide screen table       |
  |                         - Save/Restore before browse       |
  |            11/18/19 LBD - Set LRECL to 84 where it         |
  |                           should have been to start wtih   |
  |            11/10/19 LBD - Creation                         |
  |                                                            |
  * ---------------------------------------------------------- */

  parse value '' with rx null status

  /* -------------------------------------- *
  | Get into ISPF and load the ISPF panels |
  * -------------------------------------- */
  address ispexec
  'vget (zscreenw)'
  load_info = loadispf()

  call popup 'Getting git OMVS environment variables.'

  /* ---------------------------- *
  | Get the git OMVS environment |
  * ---------------------------- */
  call getenv

  /* -------------- *
  | Open our table |
  * -------------- */
  call create_tab

  /* ---------------------------------------- *
  | Load the very 1st item - the git manpage |
  * ---------------------------------------- */
  gitcmd = 'git'
  gitcat = 'git manpage'
  gitc = 1
  git.gitc = gitcmd gitcat
  'tbadd githelp'

  /* ---------------------- *
  | Now get the git guides |
  * ---------------------- */
  cmd = 'git help -g'
  x = tcmd(cmd)
  do i = 1 to so.0
    if strip(so.i) = null then iterate
    if left(so.i,1) /= ' ' then iterate
    if left(so.i,4) = 'The ' then iterate
    if left(so.i,4) = "'git" then leave
    parse value so.i with gitcmd gitcat
    gitcmd = strip(gitcmd)
    gitcat = strip(gitcat)
    gitc = gitc + 1
    git.gitc = gitcmd gitcat
    'tbadd githelp'
  end

  /* -------------------------------------------- *
  | Now process the git manpage for git commands |
  * -------------------------------------------- */
  cmd = 'man git'
  x = tcmd(cmd)
  do i = 1 to so.0
    if words(so.i) > 1 then iterate
    if left(word(so.i,1),4) /= 'git-' then iterate
    if word(so.i,1) = 'CONFIGURATION' then leave
    if pos('(1)',so.i) = 0 then iterate
    parse value so.i with gitcmd'(' .
    gitcmd = strip(gitcmd)
    j = i + 1
    gitcat = strip(so.j)
    gitc = gitc + 1
    git.gitc = gitcmd gitcat
    'tbadd githelp'
  end
  git.0 = gitc

  /* ----------------- *
  | process the table |
  * ----------------- */
  stop = 0           /* saved top of table */
  ztdsels = 0
  'tbtop githelp'
  /* ----------------- *
  | Display the table |
  * ----------------- */
  if zscreenw = 80 then
  gpanel = 'githelp'
  else gpanel = 'githelpw'
  do forever
    zcmd = null
    if stop > 0 then do
      'tbtop githelp'
      'tbskip githelp number('stop')'
    end
    if ztdsels > 0 then
    'tbdispl githelp'
    else 'tbdispl githelp panel('gpanel')'
    if rc > 4 then leave
    if row > 0 then do
      'tbtop githelp'
      'tbskip githelp number('row')'
    end

    /* -------------------- *
    | Process any commands |
    * -------------------- */
    if zcmd /= null then do
      Select
        When abbrev("REFRESH",word(zcmd,1),1) = 1 then call do_refresh
        When abbrev("ONLY",word(zcmd,1),1) = 1 then do
          ostring = translate(word(zcmd,2))
          'tbtop githelp'
          do forever
            'tbskip githelp'
            if rc > 0 then leave
            if pos(ostring,translate(gitcmd gitcat)) = 0 then
            'tbdelete githelp'
          end
          'tbquery githelp rownum(rows)'
          if rows = 0 then do
            call do_refresh
            zerrhm   = 'zigih00'
            zerralrm = 'NO'
            zerrtp   = 'NOTIFY'
            zerrsm = 'Empty.'
    zerrlm = 'The Only request resulted in zero rows. Refreshing the table.'
            'Setmsg msg(isrz003)'
          end
        end
        Otherwise nop
      end
      vsel = null
    end

    /* -------------------------- *
    | Process any row selections |
    * -------------------------- */
    if vsel /= null then do
      if gitcmd = 'git' then do
        x = tcmd('man git')
      end
      else do
        cmd = gitcmd
        x = tcmd('git help' cmd)
      end
      call browse_cmd
      drop so. se.
      vsel = null
    end
  end

  'tbend githelp'

  x = dropispf(load_info)
  exit

  /* --------------------- *
  | Create our ISPF Table |
  * --------------------- */
Create_tab:
  'tbcreate githelp names(gitcmd gitcat) nowrite share'
  return

  /* ----------------------------------- *
  | routine to browse the manpage/guide |
  * ----------------------------------- */
Browse_Cmd:
  Address TSO
  /* ------------------------------- *
  | Randomly define a DDName to use |
  * ------------------------------- */
  dd = 'dd'random(9999)
  /* ------------------------- *
  | Fixup null records in so. |
  * ------------------------- */
  lrecl = 84
  do fso = 1 to so.0
    if so.fso = null then so.fso = '  '
    if length(so.fso) > lrecl then lrecl = length(so.fso)
  end
  /* ------------------------------------------ *
  | Allocate a temporary data set for our data |
  * ------------------------------------------ */
  'Alloc f('dd') new spa(5,5) tr' ,
    'recfm(v b) lrecl('lrecl+4') blksize(0)'
  /* ----------------------- *
  | Write out the stem data |
  * ----------------------- */
  'Execio * diskw' dd '(finis stem so.'
  /* -------------------------------------------------- *
  | Access the Temporary Data Set using ISPF           |
  | Library Services.                                  |
  | Then using ISPF Browse service to browse the data. |
  | And use Library Services to Free the Data Set.     |
  * -------------------------------------------------- */
  Address ISPExec
  'control display save'
  'lminit dataid(ddb) ddname('dd')'
  'browse dataid('ddb')'
  'lmfree dataid('ddb')'
  'control display restore'
  /* ----------------------------- *
  | Last Free the z/OS Allocation |
  * ----------------------------- */
  Address TSO ,
    'Free f('dd')'
  return

  /* --------------------------- *
  | Execute the command in OMVS |
  * --------------------------- */
tcmd:
  parse arg cmd
  call popup 'Invoking command:' cmd
  cmd = 'bash &&' cmd
  x = bpxwunix(cmd,,so.,se.,env.)
  return x

popup:
  parse arg msg1
  msg2 = 'Patience . . .'
  call pfshow 'off'           /* make sure pfshow is off */
  'Addpop row(4) column(12)'
  'Control Display Lock'
  'Display Panel(gitpop)'
  'rempop'
  call pfshow 'reset'         /* make sure pfshow is reset */
  return

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

  /* ----------------------------------------------------- *
  | Get the users current OMVS enviornment for use in the |
  | bpxwunix commands.                                    |
  * ----------------------------------------------------- */
GETENV:
  cmd = 'pwd'
  x = bpxwunix(cmd,,so.,se.)
  home    = strip(so.1)
  rv=bpxwunix('env',,'env.',,,1)
  x = env.0
  x = x + 1
  env.x = 'HOME='pwd
  env.0 = x
  drop so. se.
  return

docmd:
  /* ------------------------------------ *
  | Routine 'borrowed' from Henri Kuiper |
  * ------------------------------------ */
  parse arg cmd
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

/*
>Start
>Panel tgithelp
)Attr
)Body Expand(\\)
+\-\%git manpages+\-\
%Command ===>_zcmd
+
%GITHELP+displays all the availble git commands, along with other git pages
+with more information. This will help the git novice, and git guru to better
+use git.
+
%Commands:+
    %Only+removes all rows that do not have the provided string:
          e.g. %o git
    %Refresh+is used after Only to rebuild the table
+
%Selection:
    %S+Display the manpage for the selected row.
    (may also put cursor on the row and press enter or double click)
+
)Init
 &zcont = tgithelp
)Proc
)End
>Panel githelpw
)Attr
  _ type(input) hilite(uscore)
  @ type(output) intens(high)
  $ type(output) intens(low )
)Body Expand(\\) width(&zscreenw)
+\-\%git manpages+\-\
%Command ===>_zcmd                  \ \                        %Scroll ===>_scrl
+
+Commands:  %Only+display only rows with string%Refresh+after an Only
+Selections:%S+select to view
+
+S  Command                 Description
)Model
_z+@z                      $z
)Init
 .zvars = '(vsel gitcmd gitcat)'
 .help = tgithelp
)Proc
 IF (&ZCMD = &Z)
     if (&ztdsels = 0000)
        &row = .csrrow
        if (&row ^= 0)
            if (&vsel = &z)
                &vsel = S
     if (&ztdsels ^= 0000)
          &row = &z
     IF (&vsel ^= &Z)
        if (&vsel = '=')
           &vsel = &osel
     &osel = &vsel
     if (&row = 0)
        &vsel = &Z
)End
>Panel githelp
)Attr
  _ type(input) hilite(uscore)
  @ type(output) intens(high)
  $ type(output) intens(low )
)Body Expand(\\)
+\-\%git manpages+\-\
%Command ===>_zcmd                                             %Scroll ===>_scrl
+
+Commands:  %Only+display only rows with string%Refresh+after an Only
+Selections:%S+select to view
+
+S  Command / Description
)Model
_z+@z
   $z
)Init
 .zvars = '(vsel gitcmd gitcat)'
 .help = tgithelp
)Proc
 IF (&ZCMD = &Z)
     if (&ztdsels = 0000)
        &row = .csrrow
        if (&row ^= 0)
            if (&vsel = &z)
                &vsel = S
     if (&ztdsels ^= 0000)
          &row = &z
     IF (&vsel ^= &Z)
        if (&vsel = '=')
           &vsel = &osel
     &osel = &vsel
     if (&row = 0)
        &vsel = &Z
)End
>Panel gitpop
)ATTR DEFAULT(%+_)
  @ type(output) caps(off) just(left)
)BODY WINDOW(58,4)
+
@msg1
@msg2
+
)INIT
  &ZWINTTL = 'GIT Help Popup'
)END
>End  */


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
Do_Refresh:
  'tbend githelp'
  call create_tab
  do i = 1 to git.0
    parse value git.i with gitcmd gitcat
    'tbadd githelp'
  end
  'tbtop githelp'
  stop = 0
  return
