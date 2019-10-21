#!/bin/bash
clear
WHERE=`[ -z "$SSH_CLIENT" ] && echo "OMVS"`
if [ "$WHERE" = "OMVS" ]
then
  echo "It's advised to not run this from OMVS but from a";
  echo "'real' shell (ssh/telnet in). If you wanna continue,";
  echo "type YES, otherwise press ENTER and logon via ssh.";
  read OMVS?"Continue?"
  if [ -z $OMVS ]
  then
    exit
  else
    echo "";
    echo "Ok. Let's continue"
  fi
fi
  
  
echo " _______  ___   _______  ___     ____         _______ ";
echo "|       ||   | |       ||   |   |    |       |  _    |";
echo "|____   ||   | |    ___||   |    |   |       | | |   |";
echo " ____|  ||   | |   | __ |   |    |   |       | | |   |";
echo "| ______||   | |   ||  ||   |    |   |  ___  | |_|   |";
echo "| |_____ |   | |   |_| ||   |    |   | |   | |       |";
echo "|_______||___| |_______||___|    |___| |___| |_______|";
echo "";
echo "Welcome to the installer for zigi v1r0";
echo "";
echo "This will install zigi on your mainframe.";                   
echo "";
echo "MVS datsets used by zigi are:";
echo "- ZIGI.V1R0.EXEC";
echo "- ZIGI.V1R0.PANELS";
echo "";              
echo "If you like (or have) to install zigi with another";
echo "HLQ please provide a PREFIX. Otherwise press ENTER";
echo ""
echo "If you do provide a PREFIX, don't end in a dot.";
echo "Should you decide to use the PREFIX zigi will be";
echo "installed to:";
echo "- PREFIX.ZIGI.V1R0.EXEC";
echo "- PREFIX.ZIGI.V1R0.PANELS";

echo "";
 


read PREFIX?"Prefix (or ENTER for no prefix) : "

PREFIX=` echo $PREFIX  | tr '[a-z]' '[A-Z]'`

if [ -z $PREFIX ]
  then
    EXEC=ZIGI.V1R0.EXEC
    PANELS=ZIGI.V1R0.PANELS
    GPL=ZIGI.V1R0.GPLLIC
    README=ZIGI.V1R0.README
    HLQ=ZIGI.V1R0
  else
    EXEC=${PREFIX}.ZIGI.V1R0.EXEC
    PANELS=${PREFIX}.ZIGI.V1R0.PANELS
    GPL=${PREFIX}.ZIGI.V1R0.GPLLIC
    README=${PREFIX}.ZIGI.V1R0.README
    HLQ=${PREFIX}.ZIGI.V1R0
    echo "Make sure to change the ZIGI exec to point to to this HLQ";
fi


echo ""
echo "Preparing to install to :";
echo "- $EXEC";
echo "- $PANELS";
echo "";
read GOON?"ENTER TO CONTINUE";
echo "";
echo "Here come the messages from TSO :)";
echo ""; 
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

cp -U -M ZIGI.V1R0.EXEC/* "//'$EXEC'";
cp -U -M ZIGI.V1R0.PANELS/* "//'$PANELS'";
cp -U -M ZIGI.GPLLIC "//'$GPL'";
cp -U -M ZIGI.README "//'$README'";



echo "";

echo "All done. Head on over to ISPF and execute the following command";
echo "";
echo "tso exec '${EXEC}(ZIGI)'";
echo "";
echo "";




