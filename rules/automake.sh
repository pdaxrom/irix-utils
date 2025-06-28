build_automake() {
    local PKG=automake
    local PKG_VERSION=1.18
    local PKG_EXT=tar.xz
    local PKG_SUBVERSION=
    local PKG_URL="https://ftp.gnu.org/gnu/automake//${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="GNU automake"
    local PKG_DEPS=""
    local PKG_PATH=""
    if ! test -e automake.installed; then
        download ${PKG_URL}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}
            apply_patch ${PKG_PATCH}

            mkdir -p buildx
            cd buildx
            ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

            make -j $MAKE_TASKS

            make install
        popd
        touch automake.installed
    fi
}
