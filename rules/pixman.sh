build_pixman() {
PIXMAN_VERSION=0.26.2
if ! test -e pixman.installed; then
    download https://www.cairographics.org/releases/pixman-${PIXMAN_VERSION}.tar.gz
    tar xf pixman-${PIXMAN_VERSION}.tar.gz
    pushd pixman-${PIXMAN_VERSION}
    patch -p1 < ${TOPDIR}/patches/pixman-0.26.2-irix.diff
    mkdir -p buildx
    cd buildx

    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch pixman.installed
fi
}
