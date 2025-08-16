build_glew() {
    local PKG=glew
    local PKG_VERSION=2.2.0
    local PKG_EXT=tgz
    local PKG_SUBVERSION=
    local PKG_URL="https://sourceforge.net/projects/glew/files/glew/${PKG_VERSION}/${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="The OpenGL Extension Wrangler Library is a simple tool that helps C/C++ developers initialize extensions and write portable applications."
    local PKG_DEPS=""
    local PKG_PATCH="patches/glew-2.2.0-irix.diff"
    if ! test -e glew.installed; then
        download ${PKG_URL}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}
            apply_patch ${PKG_PATCH}

            make SYSTEM=irix-gcc CC=${CROSS_PREFIX}-gcc CXX=${CROSS_PREFIX}-g++ LD=${CROSS_PREFIX}-gcc STRIP=${CROSS_PREFIX}-strip GLEW_PREFIX=$INST_PREFIX GLEW_DEST=$INST_PREFIX LIBDIR=$LIBDIR_PREFIX PKGDIR=$LIBDIR_PREFIX/pkgconfig
            make SYSTEM=irix-gcc CC=${CROSS_PREFIX}-gcc CXX=${CROSS_PREFIX}-g++ LD=${CROSS_PREFIX}-gcc STRIP=${CROSS_PREFIX}-strip GLEW_PREFIX=$INST_PREFIX GLEW_DEST=$INST_PREFIX LIBDIR=$LIBDIR_PREFIX PKGDIR=$LIBDIR_PREFIX/pkgconfig install

        popd
        touch glew.installed
    fi
}
