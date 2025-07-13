build_xrender() {
XRENDER_VERSION=0.9.0
#XRENDER_VERSION=0.9.0.2
if ! test -e libxrender.installed; then
    download https://xlibs.freedesktop.org/release/libXrender-${XRENDER_VERSION}.tar.bz2
#    download https://www.x.org/archive//individual/lib/libXrender-${XRENDER_VERSION}.tar.gz
    tar xf libXrender-${XRENDER_VERSION}.tar.bz2
    pushd libXrender-${XRENDER_VERSION}
    patch -p1 < ${TOPDIR}/patches/libXrender-0.9.0-irix.diff
    mkdir -p buildx
    cd buildx

    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libxrender.installed
fi
}
