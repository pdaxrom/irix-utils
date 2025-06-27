build_lzo() {
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
}
