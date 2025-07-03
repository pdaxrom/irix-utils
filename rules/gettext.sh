build_gettext() {
if ! test -e gettext.installed; then
    download https://ftp.gnu.org/pub/gnu/gettext/gettext-0.24.tar.gz
    tar xf gettext-0.24.tar.gz
    pushd gettext-0.24
    patch -p1 < ${TOPDIR}/patches/gettext-0.24-irix.diff
    mkdir -p build
    cd build
#    cat ${TOPDIR}/caches/*.cache > gettext.cache

cat > gettext.cache << EOF
ac_cv_have_decl_freeaddrinfo=${ac_cv_have_decl_freeaddrinfo=yes}
ac_cv_have_decl_getaddrinfo=${ac_cv_have_decl_getaddrinfo=yes}
gl_cv_func_getaddrinfo=${gl_cv_func_getaddrinfo=yes}
ac_cv_type_struct_addrinfo=${ac_cv_type_struct_addrinfo=yes}
EOF
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --disable-threads CPPFLAGS="-D_SGIAPI -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=gettext.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch gettext.installed
fi
}
