build_libffi() {
    local PKG=libffi
    local PKG_VERSION=3.2
    local PKG_EXT=tar.gz
    local PKG_SUBVERSION=
    local PKG_URL="https://gcc.gnu.org/pub/libffi/${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="ffi"
    local PKG_DEPS=""
    local PKG_PATCH="patches/libffi-3.2-irix.diff"
    if ! test -e libffi.installed; then
        download ${PKG_URL}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}
            apply_patch ${PKG_PATCH}

            autoreconf

            mkdir -p buildx
            cd buildx
            ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

            make -j $MAKE_TASKS

            make install
        popd
        touch libffi.installed
    fi
}
