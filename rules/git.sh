build_git() {
GIT_VERSION=2.35.1
if ! test -e git.installed; then
    download https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.xz
    tar xf git-${GIT_VERSION}.tar.xz
    pushd git-${GIT_VERSION}
#    patch -p1 < ${TOPDIR}/patches/git-${GIT_VERSION}.patch

#    mkdir -p b
#    cd b

#  ac_cv_iconv_omits_bom=yes \
#    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=git.cache

    make -j $MAKE_TASKS \
        CC="${CROSS_PREFIX}-gcc -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX} -lcompat_irix" AR=${CROSS_PREFIX}-ar STRIP=${CROSS_PREFIX}-strip \
        V=1 \
        USE_WOLFSSL=1 \
        OPENSSL_SHA1=1 \
        OPENSSL_SHA256=1 \
        OPENSSLDIR=$INST_PREFIX \
        NO_IPV6=y \
        HAVE_GETDELIM="" \
        NO_PTHREADS=1 \
        HAVE_CLOCK_MONOTONIC="" \
        NEEDS_LIBRT="" \
        NO_GETTEXT=1 \
        NEEDS_LIBGEN=1 \
        CURL_LDFLAGS="-L$LIBDIR_PREFIX -lcurl" \
        HOME=$INST_PREFIX \
        COMPAT_CFLAGS="-std=gnu99 -I${INST_PREFIX}/include -DDISABLE_COMPAT_GETOPT_LONG -UHAVE_SYSINFO" \

    make -j $MAKE_TASKS \
        CC="${CROSS_PREFIX}-gcc -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX} -lcompat_irix" AR=${CROSS_PREFIX}-ar STRIP=${CROSS_PREFIX}-strip \
        V=1 \
        USE_WOLFSSL=1 \
        OPENSSL_SHA1=1 \
        OPENSSL_SHA256=1 \
        OPENSSLDIR=$INST_PREFIX \
        NO_IPV6=y \
        HAVE_GETDELIM="" \
        NO_PTHREADS=1 \
        HAVE_CLOCK_MONOTONIC="" \
        NEEDS_LIBRT="" \
        NO_GETTEXT=1 \
        NEEDS_LIBGEN=1 \
        CURL_LDFLAGS="-L$LIBDIR_PREFIX -lcurl" \
        HOME=$INST_PREFIX \
        COMPAT_CFLAGS="-std=gnu99 -I${INST_PREFIX}/include -DDISABLE_COMPAT_GETOPT_LONG -UHAVE_SYSINFO" \
        install

    popd
    touch git.installed
fi
}
