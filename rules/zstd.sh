build_zstd() {
if ! test -e zstd.installed; then
    download https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz
    tar xf zstd-1.5.7.tar.gz
    pushd zstd-1.5.7

    make CC=${CROSS_PREFIX}-gcc LDFLAGS_DYNLIB= PREFIX=${INST_PREFIX} libdir=${LIBDIR_PREFIX} MOREFLAGS="-std=gnu99 -I${INST_PREFIX}/include -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"
    make CC=${CROSS_PREFIX}-gcc LDFLAGS_DYNLIB= PREFIX=${INST_PREFIX} libdir=${LIBDIR_PREFIX} MOREFLAGS="-std=gnu99 -I${INST_PREFIX}/include -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" install

    popd
    touch zstd.installed
fi
}
