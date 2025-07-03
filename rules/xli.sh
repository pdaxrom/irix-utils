build_xli() {
    local PKG=xli
    local PKG_VERSION=1.16
    local PKG_EXT=tar.bz2
    local PKG_SUBVERSION=
    local PKG_URL="http://www.boomerangsworld.de/cms/worker/downloads/${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="x11 image viewer"
    local PKG_DEPS=""
    local PKG_PATCH="patches/xli-1.17.0-irix.diff"
    if ! test -e xli.installed; then
        download ${PKG_URL}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}
            apply_patch ${PKG_PATCH}

            cp -f Makefile.std Makefile
            make -j $MAKE_TASKS GCC=${CROSS_PREFIX}-gcc SYSPATHFILE=${LIBDIR_PREFIX}/X11/Xli INSTALLDIR=${INST_PREFIX}/bin GCCFLAGS="-O2 -std=gnu99 -fstrength-reduce -finline-functions -Wno-return-mismatch -Wno-implicit-function-declaration -Wno-implicit-int -Wno-incompatible-pointer-types -I${INST_PREFIX}/include -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX} -lpng -ljpeg -lz -lXext ${COMPAT_IRIX_LIB}" gcc
            mkdir -p ${LIBDIR_PREFIX}/X11
            make -j $MAKE_TASKS GCC=${CROSS_PREFIX}-gcc SYSPATHFILE=${LIBDIR_PREFIX}/X11/Xli INSTALLDIR=${INST_PREFIX}/bin GCCFLAGS="-O2 -std=gnu99 -fstrength-reduce -finline-functions -Wno-return-mismatch -Wno-implicit-function-declaration -Wno-implicit-int -Wno-incompatible-pointer-types -I${INST_PREFIX}/include -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX} -lpng -ljpeg -lz -lXext ${COMPAT_IRIX_LIB}" install
        popd
        touch xli.installed
    fi
}
