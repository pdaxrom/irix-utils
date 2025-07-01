#!/bin/bash

set -xe

TOPDIR=$PWD

if [ "$1" = "o32" ]; then
    CROSS_PREFIX=mips-sgi-irix6o32
elif [ "$1" = "n32" ]; then
    CROSS_PREFIX=mips-sgi-irix6n32
    LIBDIR_SUFFIX=32
    IRIX_VERSION=6.5
else
    echo "$0 o32|n32"
    exit 1
fi

INST_PREFIX=/opt/pdaxrom-ng

MAKE_TASKS=16

LIBDIR_SUFFIX=${LIBDIR_SUFFIX:-}

LIBDIR_PREFIX=${INST_PREFIX}/lib${LIBDIR_SUFFIX}

export PKG_CONFIG_PATH=${LIBDIR_PREFIX}/pkgconfig

mkdir -p tmp
cd tmp

export HOST_PREFIX=${PWD}/host
mkdir -p $HOST_PREFIX
export PATH=${HOST_PREFIX}/bin:$PATH

error() {
    shift
    echo "ERROR: $@"
    exit 1
}

download() {
    test -f $(basename $1) || wget $1 || error "Download $1"
}

apply_patch() {
    for p in $@; do
	patch -p1 < ${TOPDIR}/${p}
    done
}

for f in ${TOPDIR}/rules/*.sh ; do
    source $f
done

build_compat_irix
build_zlib
build_gzip
build_bzip2
build_xz
build_liblz4
build_zstd
build_lzo
build_lzop
build_expat
build_native_gettext
build_gettext
build_tar
build_ncurses
build_readline
build_bash
build_pkg_config
build_pcre
build_native_file
build_file
build_native_libffi
build_native_glib2
build_libffi
build_pcre2
build_glib2
build_mc
build_make
build_grep
build_libressl
#build_wolfssl
build_libpsl
build_curl
build_wget
build_ssh
build_zip
build_unzip
build_git

#build_autoconf
#build_automake
#build_libtool
#build_autoconf_archive

#build_renderext
#build_xrender
#build_atk
#build_libjpeg
#build_libpng
#build_libtiff
##build_hardbuzz
#build_freetype
#build_libxml2
#build_fontconfig
#build_pixman
#build_cairo
#build_pango
#build_gtk2
#build_imlib2
#build_feh

exit 0

if false; then
if ! test -e libffi.installed; then
    download https://github.com/libffi/libffi/releases/download/v3.4.8/libffi-3.4.8.tar.gz
    tar xf libffi-3.4.8.tar.gz
    pushd libffi-3.4.8
    mkdir -p build
    cd build

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libffi.installed
fi
fi

if false; then
if ! test -e pcre2.installed; then
    download https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.45/pcre2-10.45.tar.bz2
    tar xf pcre2-10.45.tar.bz2
    pushd pcre2-10.45
    patch -p1 < ${TOPDIR}/patches/pcre2-10.45-irix.diff
    mkdir build
    cd build

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install


    popd
    touch pcre2.installed
fi
fi

if false; then
XEXTENSIONS_VERSION=1.0.1
if ! test -e xextensions.installed; then
    download https://xlibs.freedesktop.org/release/xextensions-${XEXTENSIONS_VERSION}.tar.bz2
    tar xf xextensions-${XEXTENSIONS_VERSION}.tar.bz2
    pushd xextensions-${XEXTENSIONS_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch xextensions.installed
fi
fi
