build_mc() {
if ! test -e mc.installed; then
    download https://ftp.osuosl.org/pub/midnightcommander/mc-4.8.0.tar.bz2
    tar xf mc-4.8.0.tar.bz2
    pushd mc-4.8.0
    patch -p1 < ${TOPDIR}/patches/mc-4.8.0-irix.diff
    mkdir -p b
    cd b
    cat ${TOPDIR}/caches/*.cache > mc.cache

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --with-screen=ncurses --with-x --with-ncurses-includes=${INST_PREFIX}/include --with-ncurses-libs=${LIBDIR_PREFIX} CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -lcvt -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=mc.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch mc.installed
fi
}
