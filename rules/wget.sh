build_wget() {
WGET_VERSION=1.25.0
if ! test -e wget.installed; then
    download https://mirrors.ibiblio.org/gnu/wget/wget-${WGET_VERSION}.tar.gz
    tar xf wget-${WGET_VERSION}.tar.gz
    pushd wget-${WGET_VERSION}
    patch -p1 < ${TOPDIR}/patches/wget-1.25.0-irix.diff
    mkdir -p b
    cd b

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --disable-threads --with-ssl=openssl --with-libssl-prefix=$INST_PREFIX CPPFLAGS="-std=gnu99 -Wno-implicit-function-declaration -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch wget.installed
fi
}
