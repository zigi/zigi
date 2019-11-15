#! /bin/sh

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with an effective userid of zero (0)"
   exit 1
fi

if [[ $* != *--notstupid* ]]; then

   clear
   echo "                                                              ffffffffffffffff                                  "
   echo "                                                             f::::::::::::::::f                                 "
   echo "                                                            f::::::::::::::::::f                                "
   echo "                                                            f::::::fffffff:::::f                                "
   echo " zzzzzzzzzzzzzzzzz   ooooooooooo      mmmmmmm    mmmmmmm    f:::::f       ffffffggggggggg   ggggg               "
   echo " z:::::::::::::::z oo:::::::::::oo  mm:::::::m  m:::::::mm  f:::::f            g:::::::::ggg::::g               "
   echo " z::::::::::::::z o:::::::::::::::om::::::::::mm::::::::::mf:::::::ffffff     g:::::::::::::::::g               "
   echo " zzzzzzzz::::::z  o:::::ooooo:::::om::::::::::::::::::::::mf::::::::::::f    g::::::ggggg::::::gg               "
   echo "       z::::::z   o::::o     o::::om:::::mmm::::::mmm:::::mf::::::::::::f    g:::::g     g:::::g                "
   echo "      z::::::z    o::::o     o::::om::::m   m::::m   m::::mf:::::::ffffff    g:::::g     g:::::g                "
   echo "     z::::::z     o::::o     o::::om::::m   m::::m   m::::m f:::::f          g:::::g     g:::::g                "
   echo "    z::::::z      o::::o     o::::om::::m   m::::m   m::::m f:::::f          g::::::g    g:::::g                "
   echo "   z::::::zzzzzzzzo:::::ooooo:::::om::::m   m::::m   m::::mf:::::::f         g:::::::ggggg:::::g                "
   echo "  z::::::::::::::zo:::::::::::::::om::::m   m::::m   m::::mf:::::::f          g::::::::::::::::g                "
   echo " z:::::::::::::::z oo:::::::::::oo m::::m   m::::m   m::::mf:::::::f           gg::::::::::::::g                "
   echo " zzzzzzzzzzzzzzzzz   ooooooooooo   mmmmmm   mmmmmm   mmmmmmfffffffff             gggggggg::::::g                "
   echo "                                                                                         g:::::g                "
   echo "                                                                             gggggg      g:::::g                "
   echo "               Just imagine what could have happened here now.               g:::::gg   gg:::::g                "
   echo "                 You just executed a script from the internet.                g::::::ggg:::::::g                "
   echo "                 As 'root'!. And did not bother to check it ??                 gg:::::::::::::g                 "
   echo "                                                                                 ggg::::::ggg                   "
   echo "                            use the --notstupid flag next time                      gggggg                      "
   echo ""
   exit 1
fi

clear
echo "                 _        _        _ _  "
echo "  _ __ ___   ___| | _____| |_ __ _(_) |_ "
echo " | '__/ _ \ / __| |/ / _ \ __/ _  | | __|"
echo " | | | (_) | (__|   <  __/ || (_| | | |_ "
echo " |_|  \___/ \___|_|\_\___|\__\__, |_|\__|"
echo "                             |___/     "
echo ""
echo ""

echo "git for z/OS (USS) installation"
echo ""
echo "Based on Jerry Callen's helper file"
echo "from https://forum.rocketsoftware.com/t/installing-git-for-z-os/679"
echo ""
echo "Make sure this directory has the latest versions (from Rocket) for :"
echo " - git"
echo " - bash"
echo " - perl"
echo " - gzip"
echo " - vim"
echo " - unzip"
echo ""
echo "Specify installation directory"
echo ""
read INSTALL_DIR


if [[ ! -d $INSTALL_DIR ]] ; then
  echo making $INSTALL_DIR
  mkdir -p $INSTALL_DIR
  if [[ ! -d $INSTALL_DIR ]] ; then
    echo unable to create installation directory $INSTALL_DIR
    exit 1;
  fi
fi

unpack() {
  distfile=$1
  targetdir=$2
  if [[ ! -f $distfile ]] ; then
    echo "distribution file $distfile does not exist"
    return 1
  fi
  if [[ ! -d $targetdir ]] ; then
    echo "$targetdir is not a directory"
    return 1
  fi
  $INSTALL_DIR/bin/gzip -c -d <$distfile | tar -C $targetdir -xoUXf -
  if [[ $? != 0 ]] ; then
    echo "unpacking $distfile into $targetdir failed"
    return 1
  fi

  return 0;
}

echo "installing gzip, bash, perl and git into $INSTALL_DIR"

gzipdist=gzip-*.tar
bashdist=bash-*.tar.gz
gitdist=git-*.tar.gz
perldist=perl-*.tar.gz
vimdist=vim-*.tar.gz
unzdist=unzip-*.tar.gz

# Install gzip. It is NOT compressed.
tar -C $INSTALL_DIR -xoUXf $gzipdist

if [[ ! -f $INSTALL_DIR/bin/gzip ]] ; then
  echo "installation failed for gzip"
  exit 1
else
  echo "gzip installed"
fi

# Unpack the files for bash, git and perl, vim, unzip
unpack $bashdist $INSTALL_DIR
unpack $gitdist $INSTALL_DIR
unpack $perldist $INSTALL_DIR
unpack $vimdist $INSTALL_DIR
unpack $unzdist $INSTALL_DIR

# Make sure that the permissions are correct
find $INSTALL_DIR/lib -type f -exec chmod 644 {} \;
find $INSTALL_DIR/lib -type f -name '*.so' -exec chmod 755 {} \;

# Update environment.sh with the install location
cat >$INSTALL_DIR/environment.sh <<EOF
# These lines can be added to the user's ~/.profile or they can be sourced as needed.
# Set the various PATHS to find the code for bash, git and perl
export PATH=$INSTALL_DIR/bin:\$PATH
export MANPATH=\$MANPATH:$INSTALL_DIR/man
export PERL5LIB=$INSTALL_DIR/lib/perl5:\$PERL5LIB
export LIBPATH=$INSTALL_DIR/lib/perl5/5.24.0/os390/CORE:\$LIBPATH
export GIT_SHELL=$INSTALL_DIR/bin/bash
export GIT_EXEC_PATH=$INSTALL_DIR/libexec/git-core
export GIT_TEMPLATE_DIR=$INSTALL_DIR/share/git-core/templates
export VIM=$INSTALL_DIR/share/vim/
# Set up the enhanced ASCII support flags
export _CEE_RUNOPTS="FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
export _BPXK_AUTOCVT=ON
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_IN=txt
export _TAG_REDIR_OUT=txt
EOF

# create the uninstall script
cat >uninstall.sh <<EOF
#! /bin/sh
rm environment.sh remove_dist.sh
cd $INSTALL_DIR
rm -rf bin lib libexec man share  README
EOF
chmod +x uninstall.sh

cat >remove_dist.sh <<EOF
#! /bin/sh
# remove the download files after installation
rm -f $gzipdist $bashdist $gitdist $perldist
EOF
chmod +x remove_dist.sh

# Run the perl path change script
cd $INSTALL_DIR/bin
./change_pwd_perl.sh
