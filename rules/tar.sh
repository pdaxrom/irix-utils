build_tar() {
if ! test -e tar.installed; then
    download https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz
    tar xf tar-1.35.tar.xz
    pushd tar-1.35
    patch -p1 < ${TOPDIR}/patches/tar-1.35-irix.diff

    mkdir -p build
    cd build
    cp -f ${TOPDIR}/caches/tar.cache .
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --disable-year2038  CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX} -lintl" --cache-file=tar.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch tar.installed
fi
}
