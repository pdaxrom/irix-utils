build_rxvt_unicode() {
    local PKG=rxvt-unicode
    local PKG_VERSION=9.31
    local PKG_EXT=tar.bz2
    local PKG_SUBVERSION=
    local PKG_URL="https://dist.schmorp.de/rxvt-unicode/${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="rxvt-unicode is a fork of the well known terminal emulator rxvt."
    local PKG_DEPS=""
    local PKG_PATCH="patches/rxvt-unicode-9.31-irix.diff"
    if ! test -e rxvt-unicode.installed; then
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

            ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --enable-256-color --enable-combining --enable-xft --enable-font-styles --enable-transparency --enable-fading --disable-perl --enable-mousewheel --enable-smart-resize CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX} ${EXTRA_X11_LIB}"

            make -j $MAKE_TASKS

            make install
        popd
        touch rxvt-unicode.installed
    fi
}
