build_libptytty() {
    local PKG=libptytty
    local PKG_VERSION=2.0
    local PKG_EXT=tar.gz
    local PKG_SUBVERSION=
    local PKG_URL="https://dist.schmorp.de/libptytty/${PKG}-${PKG_VERSION}.${PKG_EXT}"
    local PKG_DESC="OS independent and secure pty/tty and utmp/wtmp/lastlog handling"
    local PKG_DEPS=""
    local PKG_PATCH="patches/libptytty-2.0-irix.diff"
    if ! test -e libptytty.installed; then
        download ${PKG_URL}
        tar xf ${PKG}-${PKG_VERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}
            apply_patch ${PKG_PATCH}

            mkdir -p buildx
            cd buildx
#            ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"
            cmake -DCMAKE_TOOLCHAIN_FILE=${CMAKE_CROSS_CONF} .. -DCMAKE_LIBRARY_PATH=${LIBDIR_PREFIX} -DNCURSESW=${LIBDIR_PREFIX}/libncursesw.so -DNCURSESW_INCLUDE=${INST_PREFIX}/include -DCMAKE_CXX_FLAGS="-O3 -I${INST_PREFIX}/include" -DCMAKE_EXE_LINKER_FLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}:${LIBSTDCPP_PREFIX} -lcompat_irix" -DTTY_GID_SUPPORT_EXITCODE=1 -DCMAKE_INSTALL_PREFIX=$INST_PREFIX -DCMAKE_INSTALL_LIBDIR=$LIBDIR_PREFIX

            make -j $MAKE_TASKS

            make -j $MAKE_TASKS

            make install
        popd
        touch libptytty.installed
    fi
}
