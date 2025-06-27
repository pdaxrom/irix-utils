build_gzip() {
GZIP_VERSION=1.14
if ! test -e gzip.installed; then
    download https://ftp.gnu.org/gnu/gzip/gzip-${GZIP_VERSION}.tar.xz
    tar xf gzip-${GZIP_VERSION}.tar.xz
    pushd gzip-${GZIP_VERSION}
    apply_patch patches/gzip-1.14-irix.diff
    mkdir -p build
    cd build
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" LIBS="${COMPAT_IRIX_LIB} -lgen"
#    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -D_SGIAPI"

    make -j $MAKE_TASKS

    make install

    popd
    touch gzip.installed
fi
}
