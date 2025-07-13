build_libtiff() {
LIBTIFF_VERSION=4.7.0
if ! test -e libtiff.installed; then
    download https://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz
    tar xf tiff-${LIBTIFF_VERSION}.tar.gz
    pushd tiff-${LIBTIFF_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libtiff.installed
fi
}
