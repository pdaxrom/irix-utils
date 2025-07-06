build_pcre2() {
PCRE2_VERSION=10.45
if ! test -e pcre2.installed; then
    download https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VERSION}/pcre2-${PCRE2_VERSION}.tar.bz2
    tar xf pcre2-${PCRE2_VERSION}.tar.bz2
    pushd pcre2-${PCRE2_VERSION}
#    patch -p1 < ${TOPDIR}/patches/pcre2-${PCRE2_VERSION}-irix.diff
    mkdir -p build
    cd build

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=pcre2.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch pcre2.installed
fi
}
