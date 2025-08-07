build_native_libffi() {
    local PKG=libffi
    local PKG_VERSION=3.2
    local PKG_EXT=tar.gz
    local PKG_SUBVERSION=
    local PKG_URL="https://gcc.gnu.org/pub/libffi/${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="ffi"
    local PKG_DEPS=""
    local PKG_PATCH="patches/libffi-3.2-irix.diff"
    if ! test -e native_libffi.installed; then
        download ${PKG_URL}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}
            apply_patch ${PKG_PATCH}

            mkdir -p buildxhost
            cd buildxhost

            ../configure ${EXTRA_CONF_OPTS} --prefix=$HOST_PREFIX

            make -j $MAKE_TASKS

            make install
        popd
        touch native_libffi.installed
    fi
}
