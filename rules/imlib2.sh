build_imlib2() {
IMLIB2_VERSION=1.12.5
if ! test -e imlib2.installed; then
    download https://downloads.sourceforge.net/enlightenment/imlib2-${IMLIB2_VERSION}.tar.xz
    tar xf imlib2-${IMLIB2_VERSION}.tar.xz
    pushd imlib2-${IMLIB2_VERSION}
    patch -p1 < ${TOPDIR}/patches/imlib2-1.12.5-irix.diff
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=glib2.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch imlib2.installed
fi
}
