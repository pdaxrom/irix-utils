build_aterm() {
    local PKG=aterm
    local PKG_VERSION=1.0.1
    local PKG_EXT=tar.bz2
    local PKG_SUBVERSION=
    local PKG_URL="https://sourceforge.net/projects/aterm/files/aterm/${PKG_VERSION}/${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="AfterStep X terminal emulator"
    local PKG_DEPS=""
    local PKG_PATCH="patches/aterm-1.0.1-irix.diff"
    if ! test -e aterm.installed; then
        download ${PKG_URL}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}
            apply_patch ${PKG_PATCH}

            mkdir -p buildx
            cd buildx

            local EXTRA_X11_LIB=""
            if [ "$LIBDIR_SUFFIX" = "" ]; then
                EXTRA_X11_LIB="-lcvt"
            fi

            ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX} ${EXTRA_X11_LIB}"

            make -j $MAKE_TASKS

            make install
        popd
        touch aterm.installed
    fi
}
