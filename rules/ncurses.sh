build_ncurses() {
if ! test -e ncurses.installed; then
    download https://ftp.gnu.org/gnu/ncurses/ncurses-6.5.tar.gz
    tar xf ncurses-6.5.tar.gz
    pushd ncurses-6.5
    patch -p1 < ${TOPDIR}/patches/ncurses-6.5-irix.diff
    mkdir -p build
    cd build
    cp -f ${TOPDIR}/caches/ncurses.cache .
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --with-shared --with-cxx-shared --disable-widec --disable-stripping  CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=ncurses.cache

    make -j $MAKE_TASKS

    make install

    cd ..
    mkdir -p build-multi
    cd build-multi
#    cp -f ${TOPDIR}/caches/ncurses.cache .
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --with-shared --with-cxx-shared --disable-stripping  CPPFLAGS="-std=gnu99 -D_WCHAR_CORE_EXTENSIONS_1 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=ncurses.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch ncurses.installed
fi
}
