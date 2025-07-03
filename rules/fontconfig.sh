build_fontconfig() {
FONTCONFIG_VERSION=2.16.2
if ! test -e fontconfig.installed; then
    download https://gitlab.freedesktop.org/api/v4/projects/890/packages/generic/fontconfig/${FONTCONFIG_VERSION}/fontconfig-${FONTCONFIG_VERSION}.tar.xz
    tar xf fontconfig-${FONTCONFIG_VERSION}.tar.xz
    pushd fontconfig-${FONTCONFIG_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --enable-libxml2 CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch fontconfig.installed
fi
}
