#!/bin/sh
VER='V2R5'
clear
WHERE=`[ -z "$SSH_CLIENT" ] && echo "OMVS"`
# Let's make sure we *really* run from sh lol
SHELL=`ps -p "$$" -o comm | tail -1`
if [ "$SHELL" != "/bin/sh" ]
then
 echo "Please run the installer from sh...";
 echo "Current shell = $SHELL"
 exit
fi

echo ""
echo "                                      .zZ.     Zz ";
echo "                 ZZZZZZZZ           ZZZZZZZ ";
echo "     ZZZZZZZZZZZZZZZZZZZZZZ   ZZ   ZZZ         zZ ";
echo "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZ      ZZZ    .zZZ   ZZ ";
echo "ZZZZZZZZZZZZZZZZ    ZZZZZZZ   ZZ   ZZZ  ..zZZZ  Zz ";
echo "ZZZZZZZZZZ,       ZZZZZZZZZ   ZZZ  ZzZ      ZZ  ZZ         ZZZZZZZ";
echo "ZZZZ             ZZZZZZZZ     ZZZ   ZZZZZZZZZZZ      ZZZZZZZZZZZ ";
echo "               ZZZZZZZZ       ZZZZ    ZZZZZZ      ZZZZZZZZZg ";
echo "              ZZZZZZZZ        ZZZ            ZZZZZZZZZ ";
echo "             ZZZZZZZ              zZZZZZZZZZZZZZZ ";
echo "           ZZZZZZZ           ZZZZZZZZZZZZZZ ";
echo "         .ZZZZZZZ      ZZZZZZZZZZZZZZ ";
echo "        ZZZZZZZZZZZZZZZZZZZZZZ ";
echo "        ZZZZZZZZZZZZZZZZZ             zOS ISPF Git Interface ";
echo "       ZZZZZZZZZZZZ ";
echo "      ZZZZZZZZZg               The git interface for the rest of us";
echo "     ZZZZZZig ";
echo "    ZZZZZZi                         Henri Kuiper & Lionel Dyck ";
echo " "
echo "Welcome to the installer for zigi $VER";
echo "";
echo "This will install zigi on your mainframe.";
echo "See https://github.com/wizardofzos/zigi/wiki for more information"
echo "";
read GOON?"Hit ENTER to continue, type any character + ENTER to quit: ";
if [ -n "$GOON" ]
  then
    echo ""
    echo "zigi installer terminated :(";
    exit
fi

echo "z/OS datsets used by zigi are:";
echo "- ZIGI.$VER.EXEC";
echo "- ZIGI.$VER.PANELS";
echo "";
echo "If you like (or have) to install zigi with another";
echo "HLQ please provide a PREFIX. Otherwise press ENTER";
echo ""
echo "If you do provide a PREFIX, don't end in a dot.";
echo "Should you decide to use the PREFIX zigi will be";
echo "installed to:";
echo "- prefix.ZIGI.$VER.EXEC";
echo "- prefix.ZIGI.$VER.PANELS";

echo "";


read PREFIX?"Prefix (or ENTER for no prefix) : "

PREFIX=` echo $PREFIX  | tr '[a-z]' '[A-Z]'`

if [ -z $PREFIX ]
  then
    EXEC=ZIGI.$VER.EXEC
    PANELS=ZIGI.$VER.PANELS
    GPL=ZIGI.$VER.GPLLIC
    README=ZIGI.$VER.README
    HLQ=ZIGI.$VER.
  else
    EXEC=${PREFIX}.ZIGI.$VER.EXEC
    PANELS=${PREFIX}.ZIGI.$VER.PANELS
    GPL=${PREFIX}.ZIGI.$VER.GPLLIC
    README=${PREFIX}.ZIGI.$VER.README
    HLQ=${PREFIX}.ZIGI.$VER.
fi


echo ""
echo "Preparing to install to :";
echo "- $EXEC";
echo "- $PANELS";
echo "";
read GOON?"Hit ENTER to continue, type any character + ENTER to quit: ";
if [ -n "$GOON" ]
  then
    echo "zigi installer terminated :(";
    exit
fi

echo "";
if [ "$WHERE" != "OMVS" ]
then
 echo "Here come the messages from TSO :)";
fi
tso "ALLOC DA('$EXEC') DSORG(PO) SPACE(15,15) BLKSIZE(32720) TRACKS DIR(1) LRECL(80) RECFM(F,B) NEW  Dsntype(Library,2)";
tso "ALLOC DA('$PANELS') DSORG(PO) SPACE(15,15) BLKSIZE(32720) TRACKS DIR(1) LRECL(80) RECFM(F,B) NEW  Dsntype(Library,2)";
tso "ALLOC DA('$README') DSORG(PS) SPACE(5,1) BLKSIZE(32720) TRACKS LRECL(80) RECFM(F,B) NEW";
tso "ALLOC DA('$GPL') DSORG(PS) SPACE(5,1) BLKSIZE(32720) TRACKS LRECL(80) RECFM(F,B) NEW";

if [ "$WHERE" = "OMVS" ]
then
  tso "Free DA('$EXEC')"
  tso "Free DA('$PANELS')"
  tso "Free DA('$README')"
  tso "Free DA('$GPL')"
fi

echo "Copying execs"
cp -U -M ZIGI.EXEC/* "//'$EXEC'";
echo "Copying panels"
cp -U -M ZIGI.PANELS/* "//'$PANELS'";
echo "Copying GPL-License"
cp -U -M ZIGI.GPLLIC "//'$GPL'";
echo "Copying README"
cp -U -M ZIGI.README "//'$README'";



echo "";

echo "All done. Head on over to ISPF and execute the following command";
echo "";
echo "tso exec '${EXEC}(ZIGI)'";
echo "";
echo "";
