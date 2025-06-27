build_bzip2() {
BZIP2_VERSION=1.0.8
if ! test -e bzip2.installed; then
    download https://sourceware.org/pub/bzip2/bzip2-${BZIP2_VERSION}.tar.gz
    tar xf bzip2-${BZIP2_VERSION}.tar.gz || error "unpack bzip2"
    pushd bzip2-${BZIP2_VERSION}
    test ${TOPDIR}/patches/bzip2-${BZIP2_VERSION}-irix.diff && patch -p1 < ${TOPDIR}/patches/bzip2-${BZIP2_VERSION}-irix.diff

    make CC="${CROSS_PREFIX}-gcc -std=gnu99" AR=${CROSS_PREFIX}-ar RANLIB=${CROSS_PREFIX}-ranlib PREFIX=$INST_PREFIX LIBDIR=/lib${LIBDIR_SUFFIX} libbz2.a bzip2 bzip2recover || error "build bzip2"
    make CC="${CROSS_PREFIX}-gcc -std=gnu99" AR=${CROSS_PREFIX}-ar RANLIB=${CROSS_PREFIX}-ranlib PREFIX=$INST_PREFIX LIBDIR=/lib${LIBDIR_SUFFIX} install || error "install bzip2"

    make CC="${CROSS_PREFIX}-gcc -std=gnu99" AR=${CROSS_PREFIX}-ar RANLIB=${CROSS_PREFIX}-ranlib PREFIX=$INST_PREFIX LIBDIR=$LIBDIR_PREFIX -f Makefile-libbz2_so || error "build bzip2"
    cp -f libbz2.so.${BZIP2_VERSION} ${LIBDIR_PREFIX}
    ln -sf libbz2.so.${BZIP2_VERSION} ${LIBDIR_PREFIX}/libbz2.so.1.0
    ln -sf libbz2.so.${BZIP2_VERSION} ${LIBDIR_PREFIX}/libbz2.so

    popd
    touch bzip2.installed
fi
}
