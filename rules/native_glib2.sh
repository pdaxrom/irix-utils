build_native_glib2() {
    local OLD_PKG_CONFIG_PATH=$PKG_CONFIG_PATH
    local PKG=glib
    local PKG_VERSION=2.21
    local PKG_SUBVERSION=0
    local PKG_EXT=tar.gz
    local PKG_URL="https://download.gnome.org/sources/glib/${PKG_VERSION}/${PKG}-${PKG_VERSION}.${PKG_SUBVERSION}.${PKG_EXT}"
    local PKG_DESC="glib"
    local PKG_DEPS=""
    local PKG_PATCH="patches/glib-2.21.0-irix.diff"
    if ! test -e native_glib2.installed; then
        download ${PKG_URL}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_SUBVERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}.${PKG_SUBVERSION}
            apply_patch ${PKG_PATCH}

            export PKG_CONFIG_PATH=${HOST_PREFIX}/lib/pkgconfig
#            ./autogen.sh --prefix=$HOST_PREFIX --disable-libmount --with-pcre=internal
#            make distclean

            mkdir -p buildxhost
            cd buildxhost

            ../configure --prefix=$HOST_PREFIX --disable-libmount --with-pcre=internal

            make -j $MAKE_TASKS

            make install
        popd
        touch native_glib2.installed
    fi
    export PKG_CONFIG_PATH=$OLD_PKG_CONFIG_PATH
}
