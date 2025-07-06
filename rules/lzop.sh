build_lzop() {
if ! test -e lzop.installed; then
    download https://www.lzop.org/download/lzop-1.04.tar.gz
    tar xf lzop-1.04.tar.gz
    pushd lzop-1.04

    mkdir -p build
    cd build
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch lzop.installed
fi
}
