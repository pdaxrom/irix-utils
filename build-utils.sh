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

apply_patch() {
    for p in $@; do
	patch -p1 < ${TOPDIR}/${p}
    done
}

if [ "$DISABLE_COMPAT_IRIX_LIB" = "y" ]; then
    COMPAT_IRIX_LIB=""
    COMPAT_IRIX_LIB_STATIC=""
else
    if ! test -e compat_irix.installed; then
	cp -R ${TOPDIR}/compat-irix .
	pushd compat-irix
	make CROSS=${CROSS_PREFIX}- PREFIX=${INST_PREFIX} LIBDIR=${LIBDIR_PREFIX} IRIX_VERSION=${IRIX_VERSION} clean
	make CROSS=${CROSS_PREFIX}- PREFIX=${INST_PREFIX} LIBDIR=${LIBDIR_PREFIX} IRIX_VERSION=${IRIX_VERSION} install

	popd
	touch compat_irix.installed
    fi

    COMPAT_IRIX_LIB="-lcompat_irix"
    COMPAT_IRIX_LIB_STATIC="${LIBDIR_PREFIX}/libcompat_irix.a"
fi

if ! test -e zlib.installed; then
    download https://zlib.net/zlib-1.3.1.tar.gz
    tar xf zlib-1.3.1.tar.gz || error "unpack zlib"
    pushd zlib-1.3.1

    CC=${CROSS_PREFIX}-gcc ./configure --prefix=$INST_PREFIX --libdir=$LIBDIR_PREFIX || error "Configure zlib"
    make -j || error "Build zlib"
    make install || error "Install zlib"

    popd
    touch zlib.installed
fi

GZIP_VERSION=1.14
if ! test -e gzip.installed; then
    download https://ftp.gnu.org/gnu/gzip/gzip-${GZIP_VERSION}.tar.xz
    tar xf gzip-${GZIP_VERSION}.tar.xz
    pushd gzip-${GZIP_VERSION}
    apply_patch patches/gzip-1.14-irix.diff
    mkdir -p build
    cd build
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" LIBS="${COMPAT_IRIX_LIB} -lgen"
#    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -D_SGIAPI"

    make -j $MAKE_TASKS

    make install

    popd
    touch gzip.installed
fi

BZIP2_VERSION=1.0.8
if ! test -e bzip2.installed; then
    download https://sourceware.org/pub/bzip2/bzip2-${BZIP2_VERSION}.tar.gz
    tar xf bzip2-${BZIP2_VERSION}.tar.gz || error "unpack bzip2"
    pushd bzip2-${BZIP2_VERSION}
    test ${TOPDIR}/patches/bzip2-${BZIP2_VERSION}-irix.diff && patch -p1 < ${TOPDIR}/patches/bzip2-${BZIP2_VERSION}-irix.diff

    make CC="${CROSS_PREFIX}-gcc -std=gnu99" AR=${CROSS_PREFIX}-ar RANLIB=${CROSS_PREFIX}-ranlib PREFIX=$INST_PREFIX LIBDIR=$LIBDIR_PREFIX libbz2.a bzip2 bzip2recover || error "build bzip2"
    make CC="${CROSS_PREFIX}-gcc -std=gnu99" AR=${CROSS_PREFIX}-ar RANLIB=${CROSS_PREFIX}-ranlib PREFIX=$INST_PREFIX LIBDIR=$LIBDIR_PREFIX install || error "install bzip2"

    make CC="${CROSS_PREFIX}-gcc -std=gnu99" AR=${CROSS_PREFIX}-ar RANLIB=${CROSS_PREFIX}-ranlib PREFIX=$INST_PREFIX LIBDIR=$LIBDIR_PREFIX -f Makefile-libbz2_so || error "build bzip2"
    cp -f libbz2.so.${BZIP2_VERSION} ${LIBDIR_PREFIX}
    ln -sf libbz2.so.${BZIP2_VERSION} ${LIBDIR_PREFIX}/libbz2.so.1.0
    ln -sf libbz2.so.${BZIP2_VERSION} ${LIBDIR_PREFIX}/libbz2.so

    popd
    touch bzip2.installed
fi

if ! test -e xz.installed; then
    download https://github.com/tukaani-project/xz/releases/download/v5.8.1/xz-5.8.1.tar.xz
    tar xf xz-5.8.1.tar.xz || error "unpack xz"
    pushd xz-5.8.1
#    patch -p1 < ${TOPDIR}/patches/xz-5.8.1-irix.diff

    mkdir -p build
    cd build
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX} -lgen"

    make -j $MAKE_TASKS

    make install

    popd
    touch xz.installed
fi

if ! test -e liblz4.installed; then
    download https://github.com/lz4/lz4/releases/download/v1.10.0/lz4-1.10.0.tar.gz
    tar xf lz4-1.10.0.tar.gz
    pushd lz4-1.10.0
#    patch -p1 < ${TOPDIR}/patches/lz4-1.10.0-irix.diff

    make CC=${CROSS_PREFIX}-gcc LDFLAGS_DYNLIB= PREFIX=${INST_PREFIX} libdir=${LIBDIR_PREFIX} CFLAGS="-O3 -std=gnu99 -I${INST_PREFIX}/include -Wno-implicit-function-declaration -DHAVE_MULTITHREAD=1 -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX} ${COMPAT_IRIX_LIB}" V=1
    make CC=${CROSS_PREFIX}-gcc LDFLAGS_DYNLIB= PREFIX=${INST_PREFIX} libdir=${LIBDIR_PREFIX} CFLAGS="-O3 -std=gnu99 -I${INST_PREFIX}/include -Wno-implicit-function-declaration -DHAVE_MULTITHREAD=1 -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX} ${COMPAT_IRIX_LIB}" V=1 install

    popd
    touch liblz4.installed
fi

if ! test -e zstd.installed; then
    download https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz
    tar xf zstd-1.5.7.tar.gz
    pushd zstd-1.5.7

    make CC=${CROSS_PREFIX}-gcc LDFLAGS_DYNLIB= PREFIX=${INST_PREFIX} libdir=${LIBDIR_PREFIX} MOREFLAGS="-std=gnu99 -I${INST_PREFIX}/include -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"
    make CC=${CROSS_PREFIX}-gcc LDFLAGS_DYNLIB= PREFIX=${INST_PREFIX} libdir=${LIBDIR_PREFIX} MOREFLAGS="-std=gnu99 -I${INST_PREFIX}/include -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" install

    popd
    touch zstd.installed
fi

if ! test -e lzo.installed; then
    download https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
    tar xf lzo-2.10.tar.gz
    pushd lzo-2.10

    mkdir -p build
    cd build
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --enable-shared CPPFLAGS="-I${INST_PREFIX}/include" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch lzo.installed
fi

if ! test -e lzop.installed; then
    download https://www.lzop.org/download/lzop-1.04.tar.gz
    tar xf lzop-1.04.tar.gz
    pushd lzop-1.04

    mkdir -p build
    cd build
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

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

cat > gettext.cache << EOF
ac_cv_have_decl_freeaddrinfo=${ac_cv_have_decl_freeaddrinfo=yes}
ac_cv_have_decl_getaddrinfo=${ac_cv_have_decl_getaddrinfo=yes}
gl_cv_func_getaddrinfo=${gl_cv_func_getaddrinfo=yes}
ac_cv_type_struct_addrinfo=${ac_cv_type_struct_addrinfo=yes}
EOF
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --disable-threads CPPFLAGS="-D_SGIAPI -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=gettext.cache

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
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --disable-year2038  CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX} -lintl" --cache-file=tar.cache

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
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --with-shared --with-cxx-shared --disable-widec --disable-stripping  CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=ncurses.cache

    make -j $MAKE_TASKS

    make install

    cd ..
    mkdir -p build-multi
    cd build-multi
#    cp -f ${TOPDIR}/caches/ncurses.cache .
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --with-shared --with-cxx-shared --disable-stripping  CPPFLAGS="-std=gnu99 -D_WCHAR_CORE_EXTENSIONS_1 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=ncurses.cache

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
    cp -f ${TOPDIR}/caches/bash-5.2.37.cache readline.cache
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --enable-multibyte CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=readline.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch readline.installed
fi

BASH_VERSION=5.2.37
#BASH_VERSION=3.2

if ! test -e bash.installed; then
    download https://ftp.gnu.org/gnu/bash/bash-${BASH_VERSION}.tar.gz
    tar xf bash-${BASH_VERSION}.tar.gz
    pushd bash-${BASH_VERSION}
    test -e ${TOPDIR}/patches/bash-${BASH_VERSION}-irix.diff  && patch -p1 < ${TOPDIR}/patches/bash-${BASH_VERSION}-irix.diff
    mkdir -p build
    cd build
    test -e ${TOPDIR}/caches/bash-${BASH_VERSION}.cache && cp -f ${TOPDIR}/caches/bash-${BASH_VERSION}.cache .
    test -e ${TOPDIR}/caches-single/bash-${BASH_VERSION}.cache && cp -f ${TOPDIR}/caches-single/bash-${BASH_VERSION}.cache .
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --without-bash-malloc --with-curses --enable-multibyte --disable-werror CPPFLAGS="-std=gnu99 -D__c99 -I${INST_PREFIX}/include -I${INST_PREFIX}/include/ncurses" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" LIBS="${COMPAT_IRIX_LIB_STATIC}" --cache-file=bash-${BASH_VERSION}.cache

    make TERMCAP_LIB=${LIBDIR_PREFIX}/libncurses.a -j $MAKE_TASKS

    make TERMCAP_LIB=${LIBDIR_PREFIX}/libncurses.a install

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
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --with-internal-glib CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch pkg-config.installed
fi

if ! test -e pcre.installed; then
    download https://yer.dl.sourceforge.net/project/pcre/pcre/8.45/pcre-8.45.tar.bz2
    tar xf pcre-8.45.tar.bz2
    pushd pcre-8.45
    mkdir build
    cd build

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

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
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=glib2.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch glib2.installed
fi

if ! test -e mc.installed; then
    download https://ftp.osuosl.org/pub/midnightcommander/mc-4.8.0.tar.bz2
    tar xf mc-4.8.0.tar.bz2
    pushd mc-4.8.0
    patch -p1 < ${TOPDIR}/patches/mc-4.8.0-irix.diff
    mkdir -p b
    cd b
    cat ${TOPDIR}/caches/*.cache > mc.cache

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --with-screen=ncurses --with-x --with-ncurses-includes=${INST_PREFIX}/include --with-ncurses-libs=${LIBDIR_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=mc.cache

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
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include -DNO_GET_LOAD_AVG" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=make.cache

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
    cp -f ${TOPDIR}/caches-single/wolf.cache .

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --enable-opensslall --enable-opensslextra CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include -DWOLFSSL_IRIX -DNO_INT128" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=wolf.cache

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

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --with-wolfssl --without-libpsl --with-ca-embed=${INST_PREFIX}/etc/cacert.pem CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" LIBS="${COMPAT_IRIX_LIB} -lpthread"

    make -j $MAKE_TASKS

    make install

    popd
    touch curl.installed
fi

SSH_VERSION=9.9p2
if ! test -e openssh.installed; then
    download https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.9p2.tar.gz
    tar xf openssh-9.9p2.tar.gz
    pushd openssh-9.9p2
    patch -p1 < ${TOPDIR}/patches/openssh-9.9p2-irix.diff
    mkdir -p buildx
    cd buildx

cat > openssh.cache << EOF
ac_cv_have_decl_freeaddrinfo=${ac_cv_have_decl_freeaddrinfo=yes}
ac_cv_have_decl_getaddrinfo=${ac_cv_have_decl_getaddrinfo=yes}
gl_cv_func_getaddrinfo=${gl_cv_func_getaddrinfo=yes}
ac_cv_type_struct_addrinfo=${ac_cv_type_struct_addrinfo=yes}
ac_cv_have_struct_addrinfo=${ac_cv_have_struct_addrinfo=yes}
ac_cv_func___b64_ntop=${ac_cv_func___b64_ntop=no}
ac_cv_func___b64_pton=${ac_cv_func___b64_pton=no}
EOF

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --sysconfdir=${INST_PREFIX}/etc/ssh --without-openssl --disable-strip --with-xauth=/usr/bin/X11/xauth --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=openssh.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch openssh.installed
fi

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
