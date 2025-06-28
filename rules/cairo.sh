build_cairo() {
CAIRO_VERSION=1.12.0
if ! test -e cairo.installed; then
    download https://www.cairographics.org/releases/cairo-${CAIRO_VERSION}.tar.gz
    tar xf cairo-${CAIRO_VERSION}.tar.gz
    pushd cairo-${CAIRO_VERSION}
    patch -p1 < ${TOPDIR}/patches/cairo-1.12.0-irix.diff
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --enable-xlib-xrender=no --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include -DCAIRO_NO_MUTEX" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch cairo.installed
fi
}
