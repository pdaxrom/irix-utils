build_native_file() {
    local PKG=file
    local PKG_VERSION=5.30
    local PKG_EXT=tar.gz
    local PKG_SUBVERSION=
    local PKG_URL="ftp://ftp.astron.com/pub/file/${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="File classification command"
    local PKG_DEPS=""
    local PKG_PATH=""
    if ! test -e native_file.installed; then
        download ${PKG_URL}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}
            apply_patch ${PKG_PATCH}

            mkdir -p buildxhost
            cd buildxhost
            ../configure --prefix=$HOST_PREFIX

            make -j $MAKE_TASKS

            make install
        popd
        touch native_file.installed
    fi
}
