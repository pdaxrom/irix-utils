build_native_glib2() {
    local PKG=glib
    local PKG_VERSION=2.20
    local PKG_SUBVERSION=5
    local PKG_EXT=tar.gz
    local PKG_URL="https://download.gnome.org/sources/glib/${PKG_VERSION}/${PKG}-${PKG_VERSION}.${PKG_SUBVERSION}.${PKG_EXT}"
    local PKG_DESC="glib"
    local PKG_DEPS=""
    local PKG_PATH=""
    if ! test -e native_glib2.installed; then
        download ${PKG_URL}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_SUBVERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}.${PKG_SUBVERSION}
            apply_patch ${PKG_PATCH}

            mkdir -p buildxhost
            cd buildxhost

    ../configure --prefix=$HOST_PREFIX

            make -j $MAKE_TASKS

            make install
        popd
        touch native_glib2.installed
    fi
}
