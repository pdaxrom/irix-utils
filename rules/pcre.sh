build_pcre() {
if ! test -e pcre.installed; then
    download https://yer.dl.sourceforge.net/project/pcre/pcre/8.45/pcre-8.45.tar.bz2
    tar xf pcre-8.45.tar.bz2
    pushd pcre-8.45
    mkdir build
    cd build

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch pcre.installed
fi
}
