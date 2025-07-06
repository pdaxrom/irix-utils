build_libxml2() {
LIBXML2_VERSION=2.14.2
if ! test -e libxml2.installed; then
    download https://download.gnome.org/sources/libxml2/2.14/libxml2-${LIBXML2_VERSION}.tar.xz
    tar xf libxml2-${LIBXML2_VERSION}.tar.xz
    pushd libxml2-${LIBXML2_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --without-python CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch libxml2.installed
fi
}
