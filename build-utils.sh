#!/bin/bash

set -xe

TOPDIR=$PWD

INST_PREFIX=/opt/pdaxrom-ng

MAKE_TASKS=5

export PKG_CONFIG_PATH=${INST_PREFIX}/lib/pkgconfig

mkdir -p ../build-tmp
cd ../build-tmp

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

if ! test -e compat_irix.installed; then
    cp -R ${TOPDIR}/compat-irix .
    pushd compat-irix
    make CROSS=mips-sgi-irix5- PREFIX=${INST_PREFIX} clean
    make CROSS=mips-sgi-irix5- PREFIX=${INST_PREFIX} install

    popd
    touch compat_irix.installed
fi

COMPAT_IRIX_LIB="-lcompat_irix"
COMPAT_IRIX_LIB_STATIC="${INST_PREFIX}/lib/libcompat_irix.a"

if ! test -e zlib.installed; then
    download https://zlib.net/zlib-1.3.1.tar.gz
    tar xf zlib-1.3.1.tar.gz || error "unpack zlib"
    pushd zlib-1.3.1

    CC=mips-sgi-irix5-gcc ./configure --prefix=$INST_PREFIX || error "Configure zlib"
    make -j || error "Build zlib"
    make install || error "Install zlib"

    popd
    touch zlib.installed
fi

if ! test -e bzip2.installed; then
    download https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
    tar xf bzip2-1.0.8.tar.gz || error "unpack bzip2"
    pushd bzip2-1.0.8

    make CC="mips-sgi-irix5-gcc -std=gnu17" AR=mips-sgi-irix5-ar RANLIB=mips-sgi-irix5-ranlib PREFIX=$INST_PREFIX libbz2.a bzip2 bzip2recover || error "build bzip2"
    make CC="mips-sgi-irix5-gcc -std=gnu17" AR=mips-sgi-irix5-ar RANLIB=mips-sgi-irix5-ranlib PREFIX=$INST_PREFIX install || error "install bzip2"

    make CC="mips-sgi-irix5-gcc -std=gnu17" AR=mips-sgi-irix5-ar RANLIB=mips-sgi-irix5-ranlib PREFIX=$INST_PREFIX -f Makefile-libbz2_so || error "build bzip2"
    cp -f libbz2.so.1.0.8 ${INST_PREFIX}/lib
    ln -sf libbz2.so.1.0.8 ${INST_PREFIX}/lib/libbz2.so.1.0
    ln -sf libbz2.so.1.0.8 ${INST_PREFIX}/lib/libbz2.so

    popd
    touch bzip2.installed
fi

if ! test -e xz.installed; then
    download https://github.com/tukaani-project/xz/releases/download/v5.8.1/xz-5.8.1.tar.xz
    tar xf xz-5.8.1.tar.xz || error "unpack xz"
    pushd xz-5.8.1
    patch -p1 < ${TOPDIR}/patches/xz-5.8.1-irix.diff

    mkdir build
    cd build
    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 CPPFLAGS="-std=gnu17"

    make -j $MAKE_TASKS

    make install

    popd
    touch xz.installed
fi

if ! test -e liblz4.installed; then
    download https://github.com/lz4/lz4/releases/download/v1.10.0/lz4-1.10.0.tar.gz
    tar xf lz4-1.10.0.tar.gz
    pushd lz4-1.10.0
    patch -p1 < ${TOPDIR}/patches/lz4-1.10.0-irix.diff

    make CC=mips-sgi-irix5-gcc LDFLAGS_DYNLIB= PREFIX=${INST_PREFIX} MOREFLAGS="-I/opt/pdaxrom/include -L/opt/pdaxrom/lib -Wl,-rpath-link,/opt/pdaxrom/lib"
    make CC=mips-sgi-irix5-gcc LDFLAGS_DYNLIB= PREFIX=${INST_PREFIX} MOREFLAGS="-I/opt/pdaxrom/include -L/opt/pdaxrom/lib -Wl,-rpath-link,/opt/pdaxrom/lib" install

    popd
    touch liblz4.installed
fi

if ! test -e zstd.installed; then
    download https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz
    tar xf zstd-1.5.7.tar.gz
    pushd zstd-1.5.7

    make CC=mips-sgi-irix5-gcc LDFLAGS_DYNLIB= PREFIX=${INST_PREFIX} MOREFLAGS="-std=gnu17 -I${INST_PREFIX}/include -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib"
    make CC=mips-sgi-irix5-gcc LDFLAGS_DYNLIB= PREFIX=${INST_PREFIX} MOREFLAGS="-std=gnu17 -I${INST_PREFIX}/include -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib" install

    popd
    touch zstd.installed
fi

if ! test -e lzo.installed; then
    download https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
    tar xf lzo-2.10.tar.gz
    pushd lzo-2.10

    mkdir -p build
    cd build
    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 --enable-shared CPPFLAGS="-I${INST_PREFIX}/include" LDFLAGS="-L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib"

    make -j $MAKE_TASKS

    make install

    popd
    touch lzo.installed
fi

if ! test -e lzop.installed; then
    download https://www.lzop.org/download/lzop-1.04.tar.gz
    tar xf lzop-1.04.tar.gz
    pushd lzop-1.04
#    patch -p1 < ${TOPDIR}/patches/lzop-1.04-irix.diff

    mkdir -p build
    cd build
    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib"

    make -j $MAKE_TASKS

    make install

    popd
    touch lzop.installed
fi

if ! test -e native-gettext.installed; then
    download https://ftp.gnu.org/pub/gnu/gettext/gettext-0.24.tar.gz
    tar xf gettext-0.24.tar.gz
    rm -rf gettext-0.24-host
    mv -f gettext-0.24 gettext-0.24-host
    pushd gettext-0.24-host
    mkdir -p build
    cd build

    ../configure --prefix=$HOST_PREFIX

    make -j $MAKE_TASKS

    make install

    popd
    touch native-gettext.installed
fi

if ! test -e gettext.installed; then
    download https://ftp.gnu.org/pub/gnu/gettext/gettext-0.24.tar.gz
    tar xf gettext-0.24.tar.gz
    pushd gettext-0.24
    patch -p1 < ${TOPDIR}/patches/gettext-0.24-irix.diff
    mkdir -p build
    cd build
#    cat ${TOPDIR}/caches/*.cache > gettext.cache

    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 --disable-threads CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib" --cache-file=gettext.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch gettext.installed
fi

if ! test -e tar.installed; then
    download https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz
    tar xf tar-1.35.tar.xz
    pushd tar-1.35
    patch -p1 < ${TOPDIR}/patches/tar-1.35-irix.diff

    mkdir -p build
    cd build
    cp -f ${TOPDIR}/caches/tar.cache .
    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 --disable-year2038  CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="-L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib -lintl" --cache-file=tar.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch tar.installed
fi

if ! test -e ncurses.installed; then
    download https://ftp.gnu.org/gnu/ncurses/ncurses-6.5.tar.gz
    tar xf ncurses-6.5.tar.gz
    pushd ncurses-6.5
    patch -p1 < ${TOPDIR}/patches/ncurses-6.5-irix.diff
    mkdir -p build
    cd build
    cp -f ${TOPDIR}/caches/ncurses.cache .
    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 --with-shared --with-cxx-shared --disable-widec --disable-stripping  CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib" --cache-file=ncurses.cache

    make -j $MAKE_TASKS

    make install

    cd ..
    mkdir -p build-multi
    cd build-multi
    cp -f ${TOPDIR}/caches/ncurses.cache .
    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 --with-shared --with-cxx-shared --disable-stripping  CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib" --cache-file=ncurses.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch ncurses.installed
fi

if ! test -e readline.installed; then
    download https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz
    tar xf readline-8.2.tar.gz
    pushd readline-8.2
    patch -p1 < ${TOPDIR}/patches/readline-8.2-irix.diff
    mkdir -p build
    cd build
    cp -f ${TOPDIR}/caches/bash.cache readline.cache
    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 --enable-multibyte CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib" --cache-file=readline.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch readline.installed
fi

BASH_VERSION=5.2.37

if ! test -e bash.installed; then
    download https://ftp.gnu.org/gnu/bash/bash-${BASH_VERSION}.tar.gz
    tar xf bash-${BASH_VERSION}.tar.gz
    pushd bash-${BASH_VERSION}
    patch -p1 < ${TOPDIR}/patches/bash-${BASH_VERSION}-irix.diff
    mkdir -p build
    cd build
    cp -f ${TOPDIR}/caches/bash.cache .
    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 --without-bash-malloc --with-curses --enable-multibyte CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include -I${INST_PREFIX}/include/ncurses" LDFLAGS="-L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib" LIBS="${COMPAT_IRIX_LIB_STATIC}" --cache-file=bash.cache

    make TERMCAP_LIB=${INST_PREFIX}/lib/libncurses.a -j $MAKE_TASKS

    make TERMCAP_LIB=${INST_PREFIX}/lib/libncurses.a install

    popd
    touch bash.installed
fi

if ! test -e pkg-config.installed; then
    download https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
    tar xf pkg-config-0.29.2.tar.gz
    pushd pkg-config-0.29.2
    patch -p1 < ${TOPDIR}/patches/pkg-config-0.29.2-irix.diff
    mkdir -p build
    cd build

    glib_cv_stack_grows=no \
    glib_cv_uscore=no \
    ac_cv_func_nonposix_getpwuid_r=no \
    ac_cv_func_nonposix_getgrgid_r=no \
    ac_cv_func_posix_getpwuid_r=no \
    ac_cv_func_posix_getgrgid_r=no \
    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 --with-internal-glib CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib"

    make -j $MAKE_TASKS

    make install

    popd
    touch pkg-config.installed
fi

if false; then
if ! test -e libffi.installed; then
    download https://github.com/libffi/libffi/releases/download/v3.4.8/libffi-3.4.8.tar.gz
    tar xf libffi-3.4.8.tar.gz
    pushd libffi-3.4.8
    mkdir -p build
    cd build

    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="-L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib"

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

    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib"

    make -j $MAKE_TASKS

    make install


    popd
    touch pcre2.installed
fi
fi

if ! test -e pcre.installed; then
    download https://yer.dl.sourceforge.net/project/pcre/pcre/8.45/pcre-8.45.tar.bz2
    tar xf pcre-8.45.tar.bz2
    pushd pcre-8.45
    patch -p1 < ${TOPDIR}/patches/pcre-8.45-irix.diff
    mkdir build
    cd build

    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib"

    make -j $MAKE_TASKS

    make install


    popd
    touch pcre.installed
fi

if ! test -e native-glib2.installed; then
    download https://download.gnome.org/sources/glib/2.20/glib-2.20.5.tar.gz
    tar xf glib-2.20.5.tar.gz
    rm -rf glib-2.20.5-native
    mv -f glib-2.20.5 glib-2.20.5-native
    pushd glib-2.20.5-native
    mkdir -p b2
    cd b2

    ../configure --prefix=$HOST_PREFIX

    make -j $MAKE_TASKS

    make install

    popd
    touch native-glib2.installed
fi


if ! test -e glib2.installed; then
    download https://download.gnome.org/sources/glib/2.20/glib-2.20.5.tar.gz
    tar xf glib-2.20.5.tar.gz
    pushd glib-2.20.5
    mkdir -p b
    cd b
#    cat ${TOPDIR}/caches/*.cache > glib2.cache

    glib_cv_stack_grows=no \
    glib_cv_uscore=no \
    ac_cv_func_nonposix_getpwuid_r=no \
    ac_cv_func_nonposix_getgrgid_r=no \
    ac_cv_func_posix_getpwuid_r=no \
    ac_cv_func_posix_getgrgid_r=no \
    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib" --cache-file=glib2.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch glib2.installed
fi

if false; then
if ! test -e slang.installed; then
    download https://www.jedsoft.org/releases/slang/slang-2.3.3.tar.bz2
    tar xf slang-2.3.3.tar.bz2
    pushd slang-2.3.3

    ./configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib"

    make -j $MAKE_TASKS

    make install

    popd
    touch slang.installed
fi
fi

if ! test -e mc.installed; then
    download https://ftp.osuosl.org/pub/midnightcommander/mc-4.8.0.tar.bz2
    tar xf mc-4.8.0.tar.bz2
    pushd mc-4.8.0
    patch -p1 < ${TOPDIR}/patches/mc-4.8.0-irix.diff
    mkdir -p b
    cd b
    cat ${TOPDIR}/caches/*.cache > mc.cache

    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 --with-screen=ncurses --with-x --with-ncurses-includes=${INST_PREFIX}/include --with-ncurses-libs=${INST_PREFIX}/lib CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib" --cache-file=mc.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch mc.installed
fi

if ! test -e make.installed; then
    download https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz
    tar xf make-4.4.1.tar.gz
    pushd make-4.4.1
    mkdir -p b
    cd b
#    cat ${TOPDIR}/caches/*.cache > make.cache

    ac_cv_header_stdbool_h=yes \
    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include -DNO_GET_LOAD_AVG" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib" --cache-file=make.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch make.installed
fi

if ! test -e wolfssl.installed; then
    download https://github.com/wolfSSL/wolfssl/archive/refs/tags/v5.8.0-stable.tar.gz
    tar xf v5.8.0-stable.tar.gz
    pushd wolfssl-5.8.0-stable
    patch -p1 < ${TOPDIR}/patches/wolfssl-5.8.0-stable-irix.diff
    ./autogen.sh
    mkdir -p b
    cd b

    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 --enable-opensslall --enable-opensslextra CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include -DWOLFSSL_IRIX" LDFLAGS="${COMPAT_IRIX_LIB} -L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib"

    make -j $MAKE_TASKS

    make install

    popd
    touch wolfssl.installed
fi

if ! test -e curl.installed; then
    download https://curl.se/download/curl-8.13.0.tar.xz
    tar xf curl-8.13.0.tar.xz
    pushd curl-8.13.0
    patch -p1 < ${TOPDIR}/patches/curl-8.13.0-irix.diff
    autoreconf --force -i
    mkdir -p b
    cd b

    mkdir -p ${INST_PREFIX}/etc
    test -e ${INST_PREFIX}/etc/cacert.pem || wget https://curl.se/ca/cacert.pem -O ${INST_PREFIX}/etc/cacert.pem

    ../configure --prefix=$INST_PREFIX --host=mips-sgi-irix5 --with-wolfssl --without-libpsl --with-ca-embed=${INST_PREFIX}/etc/cacert.pem CPPFLAGS="-std=gnu17 -I${INST_PREFIX}/include" LDFLAGS="-L${INST_PREFIX}/lib -Wl,-rpath-link,${INST_PREFIX}/lib" LIBS="${COMPAT_IRIX_LIB} -lpthread"

    make -j $MAKE_TASKS

    make install

    popd
    touch curl.installed
fi
