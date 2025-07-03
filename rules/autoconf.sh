build_autoconf() {
    local PKG=autoconf
    local PKG_VERSION=2.72
    local PKG_EXT=tar.xz
    local PKG_SUBVERSION=
    local PKG_URL="https://ftp.gnu.org/gnu/autoconf//${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="GNU autoconf"
    local PKG_DEPS=""
    local PKG_PATH=""
    if ! test -e autoconf.installed; then
        download ${PKG_URL}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}
            apply_patch ${PKG_PATCH}

            mkdir -p buildx
            cd buildx
            ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

            make -j $MAKE_TASKS

            make install
        popd
        touch autoconf.installed
    fi
}
