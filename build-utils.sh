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
    local file=$(basename $1)
    if [ ! "$2" = "" ]; then
        file=$2
    fi

    test -f $file || wget $1 -O $file || error "Download $1"
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
build_libjpeg
build_libpng
build_libtiff
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
build_xli
build_iperf
