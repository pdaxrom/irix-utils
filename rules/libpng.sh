build_libpng() {
LIBPNG_VERSION=1.6.47
if ! test -e libpng.installed; then
    download https://downloads.sourceforge.net/libpng/libpng-${LIBPNG_VERSION}.tar.xz
    tar xf libpng-${LIBPNG_VERSION}.tar.xz
    pushd libpng-${LIBPNG_VERSION}
    patch -p1 < ${TOPDIR}/patches/libpng-1.6.47-apng.patch
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --disable-tools --disable-tests CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libpng.installed
fi
}
