
NDK=/home/phung/android-ndk-r7c
PLATFORM=$NDK/platforms/android-8/arch-arm/
PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86
EABIARCH=arm-linux-androideabi
ARCH=arm

if [ "$NDK" = "" ]; then
echo NDK variable not set, exiting
echo "Use: export NDK=/your/path/to/android-ndk"
exit 1
fi

function build_x264
{

    CROSS_COMPILE=$PREBUILT/bin/$EABIARCH-
    CFLAGS=" -O3 -fpic -DANDROID -DHAVE_SYS_UIO_H=1  -fasm -Wno-psabi -fno-short-enums  -fno-strict-aliasing -finline-limit=300 $OPTIMIZE_CFLAGS "
#CFLAGS=$OPTIMIZE_CFLAGS 
    export CPPFLAGS="$CFLAGS"
    export CFLAGS="$CFLAGS"
    export CXXFLAGS="$CFLAGS"
    export CXX="${CROSS_COMPILE}g++ --sysroot=$PLATFORM"
    export AS="${CROSS_COMPILE}gcc --sysroot=$PLATFORM"
    export CC="${CROSS_COMPILE}gcc --sysroot=$PLATFORM"
    export NM="${CROSS_COMPILE}nm"
    export STRIP="${CROSS_COMPILE}strip"
    export RANLIB="${CROSS_COMPILE}ranlib"
    export AR="${CROSS_COMPILE}ar"
    export LDFLAGS="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog"

    echo "configuring ... "
    ./configure --prefix=$(pwd)/$PREFIX --host=$ARCH-linux \
    --enable-shared \
    --enable-static \
    --enable-pic \
    --disable-cli \
    $ADDITIONAL_CONFIGURE_FLAG \
    || exit 1
    make clean || exit 1
    make -j4 install || exit 1
}

#CFLAGS=" -I$ARM_INC -fpic -DANDROID -fpic -mthumb-interwork -ffunction-sections -funwind-tables -fstack-protector -fno-short-enums -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__  -Wno-psabi -march=armv5te -mtune=xscale -msoft-float -mthumb -Os -fomit-frame-pointer -fno-strict-aliasing -finline-limit=64 -DANDROID  -Wa,--noexecstack -MMD -MP "

function x264_armv7 
{
#armv7-a
CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8"
PREFIX=./android/$CPU 
ADDITIONAL_CONFIGURE_FLAG=

    echo "Build x264 for $CPU "
build_x264
}


function x264_arm
{

#arm 
CPU=armeabi
OPTIMIZE_CFLAGS=""
PREFIX=./android/$CPU 
ADDITIONAL_CONFIGURE_FLAG=

    echo "Build x264 for $CPU "
build_x264
}


x264_armv7
x264_arm


