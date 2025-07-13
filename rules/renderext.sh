build_renderext() {
RENDEREXT_VERSION=0.9
if ! test -e renderext.installed; then
    download https://xlibs.freedesktop.org/release/renderext-${RENDEREXT_VERSION}.tar.bz2
    tar xf renderext-${RENDEREXT_VERSION}.tar.bz2
    pushd renderext-${RENDEREXT_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch renderext.installed
fi
}
