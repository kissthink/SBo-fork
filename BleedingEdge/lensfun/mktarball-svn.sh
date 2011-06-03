#!/bin/sh

# Download source code from a subversion repo and create a tarball
# Based on ffmpeg-mksrctarball.sh from SBo
# David Spencer <baildon.research@googlemail.com>

set -e

PRGNAM="${PRGNAM:-lensfun}"
REPO="${REPO:-svn://svn.berlios.de/lensfun}"
BRANCH="${BRANCH:-trunk}"
REVISION="${REVISION:-}"
COMPRESS="${COMPRESS:-bz2}"

if [ ! -d $PRGNAM-svn ]; then
  mkdir $PRGNAM-svn
fi

if [ "$REVISION" = "" ];then
  REVSPEC=""
else
  REVSPEC="-r $REVISION"
fi

if [ -d $PRGNAM-svn/.svn ]; then
  (
    cd $PRGNAM-svn
    echo "--> Downloading sourcecode from $REPO"
    svn update $REVSPEC
  )
else
  echo "--> Downloading sourcecode from $REPO"
  svn checkout $REVSPEC $REPO/$BRANCH $PRGNAM-svn
fi

(

  cd $PRGNAM-svn
  
  case "$COMPRESS" in
  bzip2 | bz2 )
    ZCMD="bzip2 -9"
    ZEXT="bz2"
    ;;
  gzip | gz )
    ZCMD="gzip -9"
    ZEXT="gz"
    ;;
  *)
    ZCMD="$COMPRESS"
    ZEXT="$COMPRESS"
    ;;
  esac

  VERSION="${VERSION:-$(echo $BRANCH | sed 's/-/_/g').$(svnversion)}"
  echo "--> Making the sourcecode tarball: $PRGNAM-$VERSION.tar.$ZEXT"
  tar -c --transform="s/^\\./$PRGNAM-$VERSION/" . \
    | $ZCMD > ../$PRGNAM-$VERSION.tar.$ZEXT

)

echo "--> Finished"

exit 0
