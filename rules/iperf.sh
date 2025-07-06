build_iperf() {
    local PKG=iperf
    local PKG_VERSION=3.19
    local PKG_EXT=tar.gz
    local PKG_SUBVERSION=
    local PKG_URL="https://github.com/esnet/iperf/archive/refs/tags/${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="A TCP, UDP, and SCTP network bandwidth measurement tool"
    local PKG_DEPS=""
    local PKG_PATCH="patches/iperf-3.19-irix.diff"
    if ! test -e iperf.installed; then
        download ${PKG_URL} ${PKG}-${PKG_VERSION}.${PKG_EXT}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}
            apply_patch ${PKG_PATCH}

            mkdir -p buildx
            cd buildx
            ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}:/opt/irix-gcc-o32/lib${LIBDIR_SUFFIX}"

            make -j $MAKE_TASKS

            make install
        popd
        touch iperf.installed
    fi
}
