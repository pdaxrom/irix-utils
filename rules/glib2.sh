build_glib2() {
if ! test -e glib2.installed; then
    download https://download.gnome.org/sources/glib/2.20/glib-2.20.5.tar.gz
    tar xf glib-2.20.5.tar.gz
    pushd glib-2.20.5
    mkdir -p b
    cd b
#    cat ${TOPDIR}/caches/*.cache > glib2.cache

    glib_cv_stack_grows=no \
    glib_cv_uscore=no \
    ac_cv_func_nonposix_getpwuid_r=no \
    ac_cv_func_nonposix_getgrgid_r=no \
    ac_cv_func_posix_getpwuid_r=no \
    ac_cv_func_posix_getgrgid_r=no \
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=glib2.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch glib2.installed
fi
}
