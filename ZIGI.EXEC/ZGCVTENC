# zgcvtenc - zigi convert encode routine
# by Peter Farley
# Do *not* edit <<<<<<<<<<<<<<<<<<<<<<<<<
#
# History (pushdown)
#  24 Apr 2024 - Corrections for .gitattribute awk (PF)
#  23 Apr 2024 - Integrated into zigi (LBD)
#  22 Apr 2024 - Created (PF)
# -------------------------------------------------------------
BEGIN {
    # Make the output log shell executable for debugging purposes
    print "#!/bin/sh -x"
    # Get debug value if supplied
    debug = ENVIRON["ZIGI_DEBUG"]
    if (debug == "") debug = 0
    # Get current directory name
    curdir = ENVIRON["PWD"]
    # If not avaialble, then default current directory to just "."
    if (curdir == "") curdir = "."
    # Replace any backslashes with forward slashes (for Windows debugging)
    gsub(/\\/, "/", curdir)
    # Log the current directory value
    print "# Current directory is " curdir
    # Read the .gitatributes EBCDIC file in and parse it into tables
    patndx = 0
    while (getline < ".gitattributes.ebc") {
        # delete any carriage returns from the line
        gsub("\x0D", "")
        if (debug) {
            print "NF=" NF ",$1=" $1 ",$2=" $2 ",$3=" $3 "!"
        }
        # Ignore comment lines
        if (substr($1,1,1) == "#") continue
        # Replace all periods with pattern for a literal period
        gsub(/\./, "\\\\.", $1)
        # Replace all asterisks with pattern for one-or-more of any character
        gsub(/\*/, ".+", $1)
        # Replace all forward slashes with pattern for a literal slash
        gsub(/\//, "\\\\/", $1)
        # Store the pattern
        pattern[++patndx] = $1 "$"
        # Store the "from" and "to" encodings in upper case
        if ($2 == "binary") {
            fromid[patndx] = toupper($2)
            toid[patndx] = toupper($2)
        }
        else {
            if (NF < 3) {
                print "# Error at Line " patndx ", " NF \
                      " is too few parameters"
                continue
            }
            else {
                if (split($2, idarg, /[=]/)) {
                    fromid[patndx] = toupper(idarg[2])
                }
                if (split($3, idarg, /[=]/)) {
                    toid[patndx] = toupper(idarg[2])
                }
            }
            # Force BINARY for both if either one is BINARY
            if (toid[patndx] == "BINARY" || fromid[patndx] == "BINARY") {
                fromid[patndx] = "BINARY"
                toid[patndx] = "BINARY"
            }
        }
    }
    # Close the .gitattributes EBCDIC file
    close(".gitattributes.ebc")
    # Print all the patterns to the log
    for (i = 1; i <= patndx; i++) {
        print "# Pattern[" i "]='" pattern[i] "',from='" fromid[i] \
              "',to='" toid[i] "'"
    }
    maxrc = 0
}
#
# Input lines are those expected from the output of command:
#
# ls -RFA1
#
# Each new directory line ends with a colon (":")
# Empty lines are ignored
# File name lines ending in forward slash ("/") are subdirectories
# Other lines are actual file names
#
# Ignore empty lines
NF == 0 { next }
# Remove trailing indicator ("*") for executable files
$1 ~ /\*$/ {
    $1 = substr($1, 1, length($1) - 1)
}
{
    gotfile = gotdir = 0
    # Detect start of new directory
    if (match($1, /.*\..*:$/)) {
        lsdir = substr($1, 0, length($1) - 1)
        sub(/\./, curdir, lsdir)
        print "# Now acting on files in directory " lsdir
        actdir = lsdir "/"
        next
    }
    # Detect names that are subdirectories
    if (match($1, /.+\/$/)) {
        print "# " actdir $1 " is a directory, skipped for now"
        gotdir = 1
    }
    # Otherwise we have an actual file name, find the pattern that matches
    # We search from the bottom of .gitattributes to the top
    else for (i = patndx; i > 0; i--) {
        if (match(actdir $1, pattern[i])) {
            gotfile = 1
            break
        }
    }
    # Catch any unexpected input lines and put mesage in the log
    if (!gotfile && !gotdir) {
        print "# " actdir $1 " is neither file nor directory, skipped"
        next
    }
    # If the "file" is a subdirectory, ignore this line
    if (gotdir) { next }
    if (!gotfile) {
        print "# File " actdir $1 " matched no rule, file skipped"
        next
    }
    # Convert the file only if the "from" and "to" encodings are different
    # If not debugging, exit on any non-zero return code from the executed
    # command.  If debugging, write each command to the log instead of
    # executing it.
    if (fromid[i] != toid[i]) {
        # Replace all "$" characters in the name with pattern for a literal "$"
        if (index($1, "$") > 0) gsub(/[$]/, "\\\\$", $1)
        # Log what we are about to do before each command is executed/printed
        print "# By rule " i " " actdir $1 \
              " is a file, will convert from " fromid[i] " to " toid[i]
        print "# Running cmd='/bin/iconv -f " fromid[i] " -t " toid[i] \
              " " actdir $1 " > " actdir "tmpfile'"
        if (debug) {
            print "/bin/iconv -f " fromid[i] " -t " toid[i] " " actdir $1 \
                  " > " actdir "tmpfile"
        }
        else {
            rc = system("/bin/iconv -f " fromid[i] " -t " toid[i] " " \
                        actdir $1 " > " actdir "tmpfile")
            if (rc > 0) {
                if (rc > maxrc) maxrc = rc
                print "# /bin/iconv error status " rc " for file " actdir $1
                print "# Please review contents of error log!"
                next
            }
        }
        print "# Running cmd='mv " actdir $1 " " actdir $1 ".asc'"
        if (debug) {
            print "mv " actdir $1 " " actdir $1 ".asc"
        }
        else {
            rc = system("mv " actdir $1 " " actdir $1 ".asc")
            if (rc > 0) {
                if (rc > maxrc) maxrc = rc
                print "# mv rename error status " rc " for file " actdir $1
                print "# Please review contents of error log!"
                next
            }
        }
        print "# Running cmd='mv " actdir "tmpfile " actdir $1 "'"
        if (debug) {
            print "mv " actdir "tmpfile " actdir $1
        }
        else {
            rc = system("mv " actdir "tmpfile " actdir $1)
            if (rc > 0) {
                if (rc > maxrc) maxrc = rc
                print "# mv replace error status " rc " for file " actdir $1
                print "# Please review contents of error log!"
                next
            }
        }
        print "# Running cmd='rm -f " actdir $1 ".asc'"
        if (debug) {
            print "rm -f " actdir $1 ".asc"
        }
        else {
            system("rm -f " actdir $1 ".asc")
            if (rc > 0) {
                if (rc > maxrc) maxrc = rc
                print "# rm delete error status " rc " for file " actdir $1
                print "# Please review contents of error log!"
                next
            }
        }
        print "# Running cmd='chtag -tc " toid[i] " " actdir $1 "'"
        if (debug) {
            print "chtag -tc " toid[i] " " actdir $1
        }
        else {
            system("chtag -tc " toid[i] " " actdir $1)
            if (rc > 0) {
                if (rc > maxrc) maxrc = rc
                print "# chtag -tc error status " rc " for file " actdir $1
                print "# Please review contents of error log!"
                next
            }
        }
        if ($1 == "zginstall.rex") {
            print "# Running cmd='chmod +x " actdir $1 "'"
            if (debug) {
                print "chtag -tc " toid[i] " " actdir $1
            }
            else {
                system("chmod +x " actdir $1)
                if (rc > 0) {
                    if (rc > maxrc) maxrc = rc
                    print "# chmod +x error status " rc " for file " actdir $1
                    print "# Please review contents of error log!"
                    next
                }
            }
        }
    }
    else {
        print "# By rule " i " file " actdir $1 " is treated as " \
              fromid[i] " and will not be converted"
    }
}
END { exit maxrc }
