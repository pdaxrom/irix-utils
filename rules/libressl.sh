build_libressl() {
LIBRESSL_VERSION=4.1.0
if ! test -e libressl.installed; then
    download https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz
    tar xf libressl-${LIBRESSL_VERSION}.tar.gz
    pushd libressl-${LIBRESSL_VERSION}
    patch -p1 < ${TOPDIR}/patches/libressl-4.1.0-irix.diff
    autoreconf -i

    mkdir -p build
    cd build

    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --disable-hardening CPPFLAGS="-std=gnu99 -Wno-implicit-function-declaration -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libressl.installed
fi
}
