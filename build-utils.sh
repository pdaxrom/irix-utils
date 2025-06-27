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
build_native_glib2
build_glib2
build_mc
build_make
build_grep
build_libressl
#build_wolfssl
build_pcre2
build_libpsl
build_curl
build_wget
build_ssh
build_zip
build_unzip
build_git

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

RENDEREXT_VERSION=0.9
if ! test -e renderext.installed; then
    download https://xlibs.freedesktop.org/release/renderext-${RENDEREXT_VERSION}.tar.bz2
    tar xf renderext-${RENDEREXT_VERSION}.tar.bz2
    pushd renderext-${RENDEREXT_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch renderext.installed
fi

XRENDER_VERSION=0.9.0
#XRENDER_VERSION=0.9.0.2
if ! test -e libxrender.installed; then
    download https://xlibs.freedesktop.org/release/libXrender-${XRENDER_VERSION}.tar.bz2
#    download https://www.x.org/archive//individual/lib/libXrender-${XRENDER_VERSION}.tar.gz
    tar xf libXrender-${XRENDER_VERSION}.tar.bz2
    pushd libXrender-${XRENDER_VERSION}
    patch -p1 < ${TOPDIR}/patches/libXrender-0.9.0-irix.diff
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libxrender.installed
fi

#ATK_VERSION=1.33.6
ATK_VERSION=2.1.0
if ! test -e atk.installed; then
    download https://download.gnome.org/sources/atk/2.1/atk-${ATK_VERSION}.tar.bz2
    tar xf atk-${ATK_VERSION}.tar.bz2
    pushd atk-${ATK_VERSION}
    patch -p1 < ${TOPDIR}/patches/atk-2.1.0-irix.diff
    mkdir -p buildx
    cd buildx

    glib_cv_stack_grows=no \
    glib_cv_uscore=no \
    ac_cv_func_nonposix_getpwuid_r=no \
    ac_cv_func_nonposix_getgrgid_r=no \
    ac_cv_func_posix_getpwuid_r=no \
    ac_cv_func_posix_getgrgid_r=no \
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=glib2.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch atk.installed
fi

if ! test -e libjpeg.installed; then
    download https://www.ijg.org/files/jpegsrc.v9f.tar.gz
    tar xf jpegsrc.v9f.tar.gz
    pushd jpeg-9f
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libjpeg.installed
fi

LIBPNG_VERSION=1.6.47
if ! test -e libpng.installed; then
    download https://downloads.sourceforge.net/libpng/libpng-${LIBPNG_VERSION}.tar.xz
    tar xf libpng-${LIBPNG_VERSION}.tar.xz
    pushd libpng-${LIBPNG_VERSION}
    patch -p1 < ${TOPDIR}/patches/libpng-1.6.47-apng.patch
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --disable-tools --disable-tests CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libpng.installed
fi

LIBTIFF_VERSION=4.7.0
if ! test -e libtiff.installed; then
    download https://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz
    tar xf tiff-${LIBTIFF_VERSION}.tar.gz
    pushd tiff-${LIBTIFF_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libtiff.installed
fi

if false; then
HARDBUZZ_VERSION=8.1.0
if ! test -e hardbuzz.installed; then
    download https://github.com/harfbuzz/harfbuzz/releases/download/${HARDBUZZ_VERSION}/harfbuzz-${HARDBUZZ_VERSION}.tar.xz
    tar xf harfbuzz-${HARDBUZZ_VERSION}.tar.xz
    pushd harfbuzz-${HARDBUZZ_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch hardbuzz.installed
fi
fi

FREETYPE_VERSION=2.13.3
if ! test -e freetype.installed; then
    download https://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VERSION}.tar.xz
    tar xf freetype-${FREETYPE_VERSION}.tar.xz
    pushd freetype-${FREETYPE_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch freetype.installed
fi

LIBXML2_VERSION=2.14.2
if ! test -e libxml2.installed; then
    download https://download.gnome.org/sources/libxml2/2.14/libxml2-${LIBXML2_VERSION}.tar.xz
    tar xf libxml2-${LIBXML2_VERSION}.tar.xz
    pushd libxml2-${LIBXML2_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --without-python CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libxml2.installed
fi

FONTCONFIG_VERSION=2.16.2
if ! test -e fontconfig.installed; then
    download https://gitlab.freedesktop.org/api/v4/projects/890/packages/generic/fontconfig/${FONTCONFIG_VERSION}/fontconfig-${FONTCONFIG_VERSION}.tar.xz
    tar xf fontconfig-${FONTCONFIG_VERSION}.tar.xz
    pushd fontconfig-${FONTCONFIG_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --enable-libxml2 CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch fontconfig.installed
fi

PIXMAN_VERSION=0.26.2
if ! test -e pixman.installed; then
    download https://www.cairographics.org/releases/pixman-${PIXMAN_VERSION}.tar.gz
    tar xf pixman-${PIXMAN_VERSION}.tar.gz
    pushd pixman-${PIXMAN_VERSION}
    patch -p1 < ${TOPDIR}/patches/pixman-0.26.2-irix.diff
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch pixman.installed
fi

CAIRO_VERSION=1.12.0
if ! test -e cairo.installed; then
    download https://www.cairographics.org/releases/cairo-${CAIRO_VERSION}.tar.gz
    tar xf cairo-${CAIRO_VERSION}.tar.gz
    pushd cairo-${CAIRO_VERSION}
    patch -p1 < ${TOPDIR}/patches/cairo-1.12.0-irix.diff
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --enable-xlib-xrender=no --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include -DCAIRO_NO_MUTEX" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch cairo.installed
fi

#PANGO_VERSION=1.24.1
PANGO_VERSION=1.23.0
if ! test -e pango.installed; then
    download https://download.gnome.org/sources/pango/1.23/pango-${PANGO_VERSION}.tar.gz
    tar xf pango-${PANGO_VERSION}.tar.gz
    pushd pango-${PANGO_VERSION}
#    patch -p1 < ${TOPDIR}/patches/atk-2.1.0-irix.diff
    mkdir -p buildx
    cd buildx

    glib_cv_stack_grows=no \
    glib_cv_uscore=no \
    ac_cv_func_nonposix_getpwuid_r=no \
    ac_cv_func_nonposix_getgrgid_r=no \
    ac_cv_func_posix_getpwuid_r=no \
    ac_cv_func_posix_getgrgid_r=no \
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=glib2.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch pango.installed
fi

# apt install libgdk-pixbuf2.0-bin
#GTK_VERSION=2.17.2
GTK_VERSION=2.16.6
if ! test -e gtk.installed; then
    download https://download.gnome.org/sources/gtk%2B/2.16/gtk+-${GTK_VERSION}.tar.bz2
    tar xf gtk+-${GTK_VERSION}.tar.bz2
    pushd gtk+-${GTK_VERSION}
#    patch -p1 < ${TOPDIR}/patches/gtk+-2.17.2-irix.diff
    patch -p1 < ${TOPDIR}/patches/gtk+-2.16.6-irix.diff
    mkdir -p build
    cd build

    glib_cv_stack_grows=no \
    glib_cv_uscore=no \
    ac_cv_func_nonposix_getpwuid_r=no \
    ac_cv_func_nonposix_getgrgid_r=no \
    ac_cv_func_posix_getpwuid_r=no \
    ac_cv_func_posix_getgrgid_r=no \
    gio_can_sniff=yes \
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --disable-visibility --without-libjasper --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-incompatible-pointer-types -Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=glib2.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch gtk.installed
fi

IMLIB2_VERSION=1.12.5
if ! test -e imlib2.installed; then
    download https://downloads.sourceforge.net/enlightenment/imlib2-${IMLIB2_VERSION}.tar.xz
    tar xf imlib2-${IMLIB2_VERSION}.tar.xz
    pushd imlib2-${IMLIB2_VERSION}
    patch -p1 < ${TOPDIR}/patches/imlib2-1.12.5-irix.diff
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=glib2.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch imlib2.installed
fi

FEH_VERSION=3.10.3
if ! test -e feh.installed; then
    download https://feh.finalrewind.org/feh-${FEH_VERSION}.tar.bz2
    tar xf feh-${FEH_VERSION}.tar.bz2
    pushd feh-${FEH_VERSION}
    patch -p1 < ${TOPDIR}/patches/feh-3.10.3-irix.diff

    make CC=${CROSS_PREFIX}-gcc EXTRA_CFLAGS="-I${INST_PREFIX}/include -Wno-implicit-int -Wno-incompatible-pointer-types -DHOST_NAME_MAX" EXTRA_LDLIBS="-L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" PREFIX=${INST_PREFIX} xinerama=0 mkstemps=0 verscmp=0
    make CC=${CROSS_PREFIX}-gcc EXTRA_CFLAGS="-I${INST_PREFIX}/include -Wno-implicit-int -Wno-incompatible-pointer-types -DHOST_NAME_MAX" EXTRA_LDLIBS="-L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" PREFIX=${INST_PREFIX} xinerama=0 mkstemps=0 verscmp=0 install

    popd
    touch feh.installed
fi
