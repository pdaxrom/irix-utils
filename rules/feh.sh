build_feh() {
FEH_VERSION=3.10.3
if ! test -e feh.installed; then
    download https://feh.finalrewind.org/feh-${FEH_VERSION}.tar.bz2
    tar xf feh-${FEH_VERSION}.tar.bz2
    pushd feh-${FEH_VERSION}
    patch -p1 < ${TOPDIR}/patches/feh-3.10.3-irix.diff

    make CC=${CROSS_PREFIX}-gcc EXTRA_CFLAGS="-I${INST_PREFIX}/include -Wno-implicit-int -Wno-incompatible-pointer-types -DHOST_NAME_MAX" EXTRA_LDLIBS="-L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" PREFIX=${INST_PREFIX} xinerama=0 mkstemps=0 verscmp=0
    make CC=${CROSS_PREFIX}-gcc EXTRA_CFLAGS="-I${INST_PREFIX}/include -Wno-implicit-int -Wno-incompatible-pointer-types -DHOST_NAME_MAX" EXTRA_LDLIBS="-L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" PREFIX=${INST_PREFIX} xinerama=0 mkstemps=0 verscmp=0 install

    popd
    touch feh.installed
fi
}
