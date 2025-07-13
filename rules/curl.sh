build_curl() {
if ! test -e curl.installed; then
    download https://curl.se/download/curl-8.13.0.tar.xz
    tar xf curl-8.13.0.tar.xz
    pushd curl-8.13.0
    patch -p1 < ${TOPDIR}/patches/curl-8.13.0-irix.diff
    autoreconf --force -i
    mkdir -p b
    cd b

#    mkdir -p ${INST_PREFIX}/etc
#    test -e ${INST_PREFIX}/etc/cacert.pem || wget https://curl.se/ca/cacert.pem -O ${INST_PREFIX}/etc/cacert.pem

#    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --with-wolfssl --without-libpsl --with-ca-embed=${INST_PREFIX}/etc/cacert.pem CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" LIBS="${COMPAT_IRIX_LIB} -lpthread"
#    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --with-openssl=$INST_PREFIX --without-libpsl --with-ca-embed=${INST_PREFIX}/etc/cacert.pem CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" LIBS="${COMPAT_IRIX_LIB} -lpthread"
    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --with-openssl=$INST_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" LIBS="${COMPAT_IRIX_LIB} -lpthread"

    make -j $MAKE_TASKS

    make install

    popd
    touch curl.installed
fi
}
