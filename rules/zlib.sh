build_zlib() {
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
}
