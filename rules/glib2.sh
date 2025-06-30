build_glib2() {
    local PKG=glib
    local PKG_VERSION=2.21
    local PKG_SUBVERSION=0
    local PKG_EXT=tar.gz
    local PKG_URL="https://download.gnome.org/sources/glib/${PKG_VERSION}/${PKG}-${PKG_VERSION}.${PKG_SUBVERSION}.${PKG_EXT}"
    local PKG_DESC="glib"
    local PKG_DEPS=""
    local PKG_PATCH=""
    if ! test -e glib2.installed; then
#        download ${PKG_URL}
#        tar xf ${PKG}-${PKG_VERSION}.${PKG_SUBVERSION}.${PKG_EXT}
        pushd ${PKG}-${PKG_VERSION}.${PKG_SUBVERSION}
#            apply_patch ${PKG_PATCH}

            #./autogen.sh

            mkdir -p buildx
            cd buildx
    glib_cv_stack_grows=no \
    glib_cv_uscore=no \
    ac_cv_func_nonposix_getpwuid_r=no \
    ac_cv_func_nonposix_getgrgid_r=no \
    ac_cv_func_posix_getpwuid_r=no \
    ac_cv_func_posix_getgrgid_r=no \
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --disable-libmount CPPFLAGS="-std=gnu11 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=glib2.cache

            make -j $MAKE_TASKS

            make install
        popd
        touch glib2.installed
    fi
}
