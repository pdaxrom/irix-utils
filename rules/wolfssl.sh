build_wolfssl() {
if ! test -e wolfssl.installed; then
    download https://github.com/wolfSSL/wolfssl/archive/refs/tags/v5.8.0-stable.tar.gz
    tar xf v5.8.0-stable.tar.gz
    pushd wolfssl-5.8.0-stable
    patch -p1 < ${TOPDIR}/patches/wolfssl-5.8.0-stable-irix.diff
    ./autogen.sh
    mkdir -p b
    cd b
    cp -f ${TOPDIR}/caches-single/wolfssl.cache .

#    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --enable-openssh --enable-32bit --enable-kcapi=no CPPFLAGS="-std=gnu11 -I${INST_PREFIX}/include -DWOLFSSL_IRIX -DNO_INT128 -DWC_RNG_SEED_CB" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=wolf.cache
    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --enable-openssh --enable-32bit --enable-kcapi=no CPPFLAGS="-std=gnu11 -I${INST_PREFIX}/include -DWOLFSSL_IRIX -DNO_INT128 -DWC_RNG_SEED_CB" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=wolfssl.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch wolfssl.installed
fi
}
