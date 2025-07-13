build_libjpeg() {
if ! test -e libjpeg.installed; then
    download https://www.ijg.org/files/jpegsrc.v9f.tar.gz
    tar xf jpegsrc.v9f.tar.gz
    pushd jpeg-9f
    mkdir -p buildx
    cd buildx

    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libjpeg.installed
fi
}
