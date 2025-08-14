build_gtk2() {
# apt install libgdk-pixbuf2.0-bin
#GTK_VERSION=2.17.2
GTK_VERSION=2.16.6
if ! test -e gtk2.installed; then
    download https://download.gnome.org/sources/gtk%2B/2.16/gtk+-${GTK_VERSION}.tar.bz2
    tar xf gtk+-${GTK_VERSION}.tar.bz2
    pushd gtk+-${GTK_VERSION}
#    patch -p1 < ${TOPDIR}/patches/gtk+-2.17.2-irix.diff
    patch -p1 < ${TOPDIR}/patches/gtk+-2.16.6-irix.diff
    mkdir -p build
    cd build

    glib_cv_stack_grows=no \
    glib_cv_uscore=no \
    ac_cv_func_nonposix_getpwuid_r=no \
    ac_cv_func_nonposix_getgrgid_r=no \
    ac_cv_func_posix_getpwuid_r=no \
    ac_cv_func_posix_getgrgid_r=no \
    gio_can_sniff=yes \
    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --disable-visibility --without-libjasper --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib${LIBDIR_SUFFIX}" CPPFLAGS="-Wno-incompatible-pointer-types -Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=glib2.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch gtk2.installed
fi
}
