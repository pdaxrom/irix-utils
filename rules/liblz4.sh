build_liblz4() {
if ! test -e liblz4.installed; then
    download https://github.com/lz4/lz4/releases/download/v1.10.0/lz4-1.10.0.tar.gz
    tar xf lz4-1.10.0.tar.gz
    pushd lz4-1.10.0
#    patch -p1 < ${TOPDIR}/patches/lz4-1.10.0-irix.diff

    make CC=${CROSS_PREFIX}-gcc LDFLAGS_DYNLIB= PREFIX=${INST_PREFIX} libdir=${LIBDIR_PREFIX} CFLAGS="-O3 -std=gnu99 -I${INST_PREFIX}/include -Wno-implicit-function-declaration -DHAVE_MULTITHREAD=1 -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX} ${COMPAT_IRIX_LIB}" V=1
    make CC=${CROSS_PREFIX}-gcc LDFLAGS_DYNLIB= PREFIX=${INST_PREFIX} libdir=${LIBDIR_PREFIX} CFLAGS="-O3 -std=gnu99 -I${INST_PREFIX}/include -Wno-implicit-function-declaration -DHAVE_MULTITHREAD=1 -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX} ${COMPAT_IRIX_LIB}" V=1 install

    popd
    touch liblz4.installed
fi
}
