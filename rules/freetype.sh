build_freetype() {
FREETYPE_VERSION=2.13.3
if ! test -e freetype.installed; then
    download https://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VERSION}.tar.xz
    tar xf freetype-${FREETYPE_VERSION}.tar.xz
    pushd freetype-${FREETYPE_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch freetype.installed
fi
}
