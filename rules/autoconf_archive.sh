build_autoconf_archive() {
    local PKG=autoconf-archive
    local PKG_VERSION=2024.10.16
    local PKG_EXT=tar.xz
    local PKG_SUBVERSION=
    local PKG_URL="https://mirror.team-cymru.com/gnu/autoconf-archive//${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="GNU autoconf archive"
    local PKG_DEPS=""
    local PKG_PATH=""
    if ! test -e autoconf-archive.installed; then
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
        touch autoconf-archive.installed
    fi
}
