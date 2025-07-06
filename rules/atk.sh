build_atk() {
#ATK_VERSION=1.33.6
ATK_VERSION=2.1.0
if ! test -e atk.installed; then
    download https://download.gnome.org/sources/atk/2.1/atk-${ATK_VERSION}.tar.bz2
    tar xf atk-${ATK_VERSION}.tar.bz2
    pushd atk-${ATK_VERSION}
    patch -p1 < ${TOPDIR}/patches/atk-2.1.0-irix.diff
    mkdir -p buildx
    cd buildx

    glib_cv_stack_grows=no \
    glib_cv_uscore=no \
    ac_cv_func_nonposix_getpwuid_r=no \
    ac_cv_func_nonposix_getgrgid_r=no \
    ac_cv_func_posix_getpwuid_r=no \
    ac_cv_func_posix_getgrgid_r=no \
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=glib2.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch atk.installed
fi
}
