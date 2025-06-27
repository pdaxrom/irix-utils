build_readline() {
if ! test -e readline.installed; then
    download https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz
    tar xf readline-8.2.tar.gz
    pushd readline-8.2
    patch -p1 < ${TOPDIR}/patches/readline-8.2-irix.diff
    mkdir -p build
    cd build
    cp -f ${TOPDIR}/caches/bash-5.2.37.cache readline.cache
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --enable-multibyte CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=readline.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch readline.installed
fi
}
