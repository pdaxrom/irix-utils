build_xz() {
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
}
