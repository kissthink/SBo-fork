#!/bin/sh

# Download source code from a git repo and create a tarball
# Based on ffmpeg-mksrctarball.sh from SBo
# David Spencer <baildon.research@googlemail.com>

set -e

PRGNAM="${PRGNAM:-qgis}"
REPO="${REPO:-git://github.com/qgis/Quantum-GIS}"
BRANCH="${BRANCH:-release-1_7_0}"
REVISION="${REVISION:-}"
COMPRESS="${COMPRESS:-bz2}"

if [ ! -d $PRGNAM-git ]; then
  mkdir $PRGNAM-git
fi

if [ -d $PRGNAM-git/.git ]; then
  (
    cd $PRGNAM-git
    ORIGIN="$(git config --get remote.origin.url)"
    if [ "$ORIGIN" != "$REPO" ]; then
       echo "--> Warning: ignoring repository origin $ORIGIN"
    fi
    git checkout $BRANCH
    echo "--> Downloading sourcecode from $REPO"
    git pull $REPO $BRANCH
  )
else
  echo "--> Downloading sourcecode from $REPO"
  git clone -b $BRANCH $REPO $PRGNAM-git
fi

(

  cd $PRGNAM-git
  if [ "$REVISION" != "" ]; then
    git checkout $REVISION
  else
    REVISION=$(git rev-list --max-count=1 HEAD | cut -c1-8)
  fi

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

  VERSION="${VERSION:-$(echo $BRANCH | sed 's/-/_/g').$REVISION}"
  echo "--> Making the sourcecode tarball: $PRGNAM-$VERSION.tar.$ZEXT"
  tar -c --transform="s/^\\./$PRGNAM-$VERSION/" . \
    | $ZCMD > ../$PRGNAM-$VERSION.tar.$ZEXT

)

echo "--> Finished"

exit 0
