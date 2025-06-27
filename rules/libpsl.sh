build_libpsl() {
LIBPSL_VERSION=0.21.5
if ! test -e libpsl.installed; then
    download https://github.com/rockdaboot/libpsl/releases/download/${LIBPSL_VERSION}/libpsl-${LIBPSL_VERSION}.tar.gz
    tar xf libpsl-${LIBPSL_VERSION}.tar.gz
    pushd libpsl-${LIBPSL_VERSION}
    patch -p1 < ${TOPDIR}/patches/libpsl-0.21.5-irix.diff
    mkdir -p b
    cd b

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=libpsl.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch libpsl.installed
fi
}
