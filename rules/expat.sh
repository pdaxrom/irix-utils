build_expat() {
LIBEXPAT_VERSION=2.7.1
if ! test -e libexpat.installed; then
    download https://github.com/libexpat/libexpat/releases/download/R_2_7_1/expat-${LIBEXPAT_VERSION}.tar.xz
    tar xvf expat-${LIBEXPAT_VERSION}.tar.xz
    pushd expat-${LIBEXPAT_VERSION}

    mkdir -p build
    cd build
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libexpat.installed
fi
}
