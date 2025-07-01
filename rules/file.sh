build_file() {
    local PKG=file
    local PKG_VERSION=5.30
    local PKG_EXT=tar.gz
    local PKG_SUBVERSION=
    local PKG_URL="ftp://ftp.astron.com/pub/file/${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="File classification command"
    local PKG_DEPS=""
    local PKG_PATH=""
    if ! test -e file.installed; then
#        download ${PKG_URL}
#        tar xf ${PKG}-${PKG_VERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}
#            apply_patch ${PKG_PATCH}

            mkdir -p buildx
            cd buildx
            ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

            make -j $MAKE_TASKS

            make install
        popd
        touch file.installed
    fi
}
