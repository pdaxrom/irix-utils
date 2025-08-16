build_SDL2() {
    local PKG=SDL2
    local PKG_VERSION=2.0.14
    local PKG_EXT=tar.gz
    local PKG_SUBVERSION=
    local PKG_URL="https://www.libsdl.org/release/${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="The Simple DirectMedia Layer Version 2"
    local PKG_DEPS=""
    local PKG_PATCH="patches/SDL2-${PKG_VERSION}-irix.diff"
    if ! test -e SDL2.installed; then
        download ${PKG_URL}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}
            apply_patch ${PKG_PATCH}

            mkdir -p buildx
            cd buildx
#            ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --disable-video-opengles --disable-video-opengles1 --disable-video-opengles2 --disable-video-vulkan --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib${LIBDIR_SUFFIX}" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"
            ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib${LIBDIR_SUFFIX}" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

            make -j $MAKE_TASKS

            make install
        popd
        touch SDL2.installed
    fi
}
