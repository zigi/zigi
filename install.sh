#!/bin/bash
clear
WHERE=`[ -z "$SSH_CLIENT" ] && echo "OMVS"`
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
echo "Welcome to the installer for zigi v1r0";
echo "";
echo "This will install zigi on your mainframe.";                   
echo "See https://github.com/wizardofzos/zigi/wiki for more information"
echo "";
read GOON?"Hit ENTER to continue, type any chracter + ENTER to quit: ";
if [ -n "$GOON" ]
  then
    echo ""               
    echo "zigi installer terminated :(";
    exit
fi

echo "MVS datsets used by zigi are:";
echo "- ZIGI.V1R1.EXEC";
echo "- ZIGI.V1R1.PANELS";
echo "";              
echo "If you like (or have) to install zigi with another";
echo "HLQ please provide a PREFIX. Otherwise press ENTER";
echo ""
echo "If you do provide a PREFIX, don't end in a dot.";
echo "Should you decide to use the PREFIX zigi will be";
echo "installed to:";
echo "- prefix.ZIGI.V1R1.EXEC";
echo "- prefix.ZIGI.V1R1.PANELS";

echo "";
 


read PREFIX?"Prefix (or ENTER for no prefix) : "

PREFIX=` echo $PREFIX  | tr '[a-z]' '[A-Z]'`

if [ -z $PREFIX ]
  then
    EXEC=ZIGI.V1R1.EXEC
    PANELS=ZIGI.V1R1.PANELS
    GPL=ZIGI.V1R1.GPLLIC
    README=ZIGI.V1R1.README
    HLQ=ZIGI.V1R1
  else
    EXEC=${PREFIX}.ZIGI.V1R1.EXEC
    PANELS=${PREFIX}.ZIGI.V1R1.PANELS
    GPL=${PREFIX}.ZIGI.V1R1.GPLLIC
    README=${PREFIX}.ZIGI.V1R1.README
    HLQ=${PREFIX}.ZIGI.V1R1
fi


echo ""
echo "Preparing to install to :";
echo "- $EXEC";
echo "- $PANELS";
echo "";
read GOON?"Hit ENTER to continue, type any chracter + ENTER to quit: ";
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
tso "ALLOC DA('$EXEC') DSORG(PO) SPACE(5,1) BLKSIZE(8000) TRACKS DIR(2) LRECL(80) RECFM(F,B) NEW";
tso "ALLOC DA('$PANELS') DSORG(PO) SPACE(5,1) BLKSIZE(8000) TRACKS DIR(4) LRECL(80) RECFM(F,B) NEW";
tso "ALLOC DA('$README') DSORG(PS) SPACE(5,1) BLKSIZE(8000) TRACKS LRECL(80) RECFM(F,B) NEW";
tso "ALLOC DA('$GPL') DSORG(PS) SPACE(5,1) BLKSIZE(8000) TRACKS LRECL(80) RECFM(F,B) NEW";

if [ "$WHERE" = "OMVS" ]
then
  tso "Free DA('$EXEC')"
  tso "Free DA('$PANELS')"
  tso "Free DA('$README')"
  tso "Free DA('$GPL')"
fi

echo "Copying execs"
cp -U -M ZIGI.V1R0.EXEC/* "//'$EXEC'";
echo "Copying panels"
cp -U -M ZIGI.V1R0.PANELS/* "//'$PANELS'";
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




