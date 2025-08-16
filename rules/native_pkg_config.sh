build_native_pkg_config() {
if ! test -e native_pkg-config.installed; then
    download https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
    tar xf pkg-config-0.29.2.tar.gz
    pushd pkg-config-0.29.2
    patch -p1 < ${TOPDIR}/patches/pkg-config-0.29.2-irix.diff
    mkdir -p build-native
    cd build-native

    ../configure ${EXTRA_CONF_OPTS} --prefix=$HOST_PREFIX --with-internal-glib --libdir=$LIBDIR_PREFIX --datadir=$LIBDIR_PREFIX

    make -j $MAKE_TASKS

    make install

    popd
    touch native_pkg-config.installed
fi
}
