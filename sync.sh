#!/bin/sh

set -e

SCRIPT_DIR=$( (cd -P $(dirname $0) && pwd) )
DIST_DIR_BASE=${DIST_DIR_BASE:="$SCRIPT_DIR/dist"}
x264_BASEDIR=x264
if [ -d $x264_BASEDIR ]
then
  echo "Found x264 source directory, no need to fetch from git..."
else
  echo "Fetching x264 from git://git.videolan.org/ffmpeg.git..."
  git clone git://git.videolan.org/x264.git $x264_BASEDIR
fi

#ARCHS=${ARCHS:-"armv6 armv7 i386"}
ARCHS=${ARCHS:-"armv7 x86_64 i386"}

for ARCH in $ARCHS
do
    x264_DIR=$x264_BASEDIR-$ARCH
    echo "Syncing source for $ARCH to directory $x264_DIR"
    rsync $x264_BASEDIR/ $x264_DIR/ --exclude '.*' -a --delete
done
