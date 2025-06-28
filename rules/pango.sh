build_pango() {
#PANGO_VERSION=1.24.1
PANGO_VERSION=1.23.0
if ! test -e pango.installed; then
    download https://download.gnome.org/sources/pango/1.23/pango-${PANGO_VERSION}.tar.gz
    tar xf pango-${PANGO_VERSION}.tar.gz
    pushd pango-${PANGO_VERSION}
#    patch -p1 < ${TOPDIR}/patches/atk-2.1.0-irix.diff
    mkdir -p buildx
    cd buildx

    glib_cv_stack_grows=no \
    glib_cv_uscore=no \
    ac_cv_func_nonposix_getpwuid_r=no \
    ac_cv_func_nonposix_getgrgid_r=no \
    ac_cv_func_posix_getpwuid_r=no \
    ac_cv_func_posix_getgrgid_r=no \
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=glib2.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch pango.installed
fi
}
