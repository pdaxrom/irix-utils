build_hardbuzz() {
HARDBUZZ_VERSION=8.1.0
if ! test -e hardbuzz.installed; then
    download https://github.com/harfbuzz/harfbuzz/releases/download/${HARDBUZZ_VERSION}/harfbuzz-${HARDBUZZ_VERSION}.tar.xz
    tar xf harfbuzz-${HARDBUZZ_VERSION}.tar.xz
    pushd harfbuzz-${HARDBUZZ_VERSION}
    mkdir -p buildx
    cd buildx

    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch hardbuzz.installed
fi
}
