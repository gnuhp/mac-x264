#!/bin/sh

PLATFORMBASE=$(xcode-select -print-path)"/Platforms"
IOSSDKVERSION=6.0

set -e

SCRIPT_DIR=$( (cd -P $(dirname $0) && pwd) )
DIST_DIR_BASE=${DIST_DIR_BASE:="$SCRIPT_DIR/dist"}
if [ ! -d x264 ]
then
  echo "ffmpeg source directory does not exist, run sync.sh"
fi

#ARCHS=${ARCHS:-"armv6 armv7 i386"}
#ARCHS=${ARCHS:-"x86_64 armv7  "}
ARCHS=${ARCHS:-"i386 armv7  "}

GAS=${SCRIPT_DIR}/gas-preprocessor 

for ARCH in $ARCHS
do
    x264_DIR=x264-$ARCH
    if [ ! -d $x264_DIR ]
    then
      echo "Directory $x264_DIR does not exist, run sync.sh"
      exit 1
    fi
    echo "Compiling source for $ARCH in directory $x264_DIR"

    cd $x264_DIR

    DIST_DIR=$DIST_DIR_BASE-$ARCH
    mkdir -p $DIST_DIR

    case $ARCH in
        armv6)
        echo "NOT SUPPORT NOW"
             ;;
        armv7)
            EXTRA_FLAGS=""
            PLATFORM="${PLATFORMBASE}/iPhoneOS.platform"
            COMPILER="llvm-gcc"
            IOSSDK=iPhoneOS${IOSSDKVERSION}
            HOST="--host=arm-apple-darwin --disable-asm"

            export CC="${PLATFORM}/Developer/usr/bin/$COMPILER --sysroot="${PLATFORM}/Developer/SDKs/${IOSSDK}.sdk" "
            export CXX="${PLATFORM}/Developer/usr/bin/llvm-g++ --sysroot="${PLATFORM}/Developer/SDKs/${IOSSDK}.sdk" "
            export AS="${PLATFORM}/Developer/usr/bin/$COMPILER --sysroot="${PLATFORM}/Developer/SDKs/${IOSSDK}.sdk" "
            export NM="${PLATFORM}/Developer/usr/bin/nm "
            export STRIP="${PLATFORM}/Developer/usr/bin/strip "
            export RANLIB="${PLATFORM}/Developer/usr/bin/ranlib "
            export AR="${PLATFORM}/Developer/usr/bin/ar "

            ./configure --prefix="$DIST_DIR"  $HOST \
                                  --enable-shared \
                                  --enable-static \
                                  --enable-pic \
                                  --disable-cli \
                                  --extra-ldflags=" -L${PLATFORM}/Developer/SDKs/${IOSSDK}.sdk/usr/lib/system -arch $ARCH " \
                                  --extra-cflags="-arch $ARCH $EXTRA_CFLAGS" \
                                  || exit 1




            ;;
        i386)
            EXTRA_FLAGS=""
            EXTRA_CFLAGS=""
            PLATFORM="${PLATFORMBASE}/iPhoneSimulator.platform"
            COMPILER="gcc"
            IOSSDK=iPhoneSimulator${IOSSDKVERSION}

            export CC="${PLATFORM}/Developer/usr/bin/$COMPILER "
            export CXX="${PLATFORM}/Developer/usr/bin/g++ "
            export AS="${PLATFORM}/Developer/usr/bin/$COMPILER "
            export NM="${PLATFORM}/Developer/usr/bin/nm "
            export STRIP="${PLATFORM}/Developer/usr/bin/strip "
            export RANLIB="${PLATFORM}/Developer/usr/bin/ranlib "
            export AR="${PLATFORM}/Developer/usr/bin/ar "

            ./configure --prefix="$DIST_DIR"  --host=i386-apple-darwin\
                                  --sysroot="${PLATFORM}/Developer/SDKs/${IOSSDK}.sdk" \
                                  --enable-shared \
                                  --enable-static \
                                  --enable-pic \
                                  --disable-cli \
                                  --disable-asm \
                                  --extra-ldflags=" -L${PLATFORM}/Developer/SDKs/${IOSSDK}.sdk/usr/lib/system -arch $ARCH " \
                                  --extra-cflags="-arch $ARCH $EXTRA_CFLAGS" \
                                  || exit 1

            ;;

        x86_64)
            EXTRA_FLAGS=""
            EXTRA_CFLAGS=""
            PLATFORM="${PLATFORMBASE}/iPhoneSimulator.platform"
            COMPILER="gcc"
            IOSSDK=iPhoneSimulator${IOSSDKVERSION}

            export CC="${PLATFORM}/Developer/usr/bin/$COMPILER "
            export CXX="${PLATFORM}/Developer/usr/bin/g++ "
            export AS="${PLATFORM}/Developer/usr/bin/$COMPILER "
            export NM="${PLATFORM}/Developer/usr/bin/nm "
            export STRIP="${PLATFORM}/Developer/usr/bin/strip "
            export RANLIB="${PLATFORM}/Developer/usr/bin/ranlib "
            export AR="${PLATFORM}/Developer/usr/bin/ar "

            ./configure --prefix="$DIST_DIR"  \
                                  --enable-shared \
                                  --enable-static \
                                  --enable-pic \
                                  --disable-cli \
                                  --disable-asm \
                                  || exit 1



            ;;
        *)
            echo "Unsupported architecture ${ARCH}"
            exit 1
            ;;
    esac

    echo "Configuring x264 for $ARCH..."

    echo "Dist dir : $DIST_DIR"



    

    
    echo "Installing x264 for $ARCH..."
    make clean && \
    make -j8 V=1 && \
    make install
    cd $SCRIPT_DIR

done
