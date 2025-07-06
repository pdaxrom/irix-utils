build_ssh() {
SSH_VERSION=10.0p2
if ! test -e openssh.installed; then
    download https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${SSH_VERSION}.tar.gz
    tar xf openssh-${SSH_VERSION}.tar.gz
    pushd openssh-10.0p1
    patch -p1 < ${TOPDIR}/patches/openssh-${SSH_VERSION}-irix.diff
#    patch -p1 < ${TOPDIR}/patches/openssh-${SSH_VERSION}.patch
#    patch -p1 < ${TOPDIR}/patches/openssh-${SSH_VERSION}-wolfssl-irix.diff
    autoreconf

    mkdir -p buildx
    cd buildx

#cat > openssh.cache << EOF
#ac_cv_have_decl_freeaddrinfo=${ac_cv_have_decl_freeaddrinfo=yes}
#ac_cv_have_decl_getaddrinfo=${ac_cv_have_decl_getaddrinfo=yes}
#gl_cv_func_getaddrinfo=${gl_cv_func_getaddrinfo=yes}
#ac_cv_type_struct_addrinfo=${ac_cv_type_struct_addrinfo=yes}
#ac_cv_have_struct_addrinfo=${ac_cv_have_struct_addrinfo=yes}
#ac_cv_func___b64_ntop=${ac_cv_func___b64_ntop=no}
#ac_cv_func___b64_pton=${ac_cv_func___b64_pton=no}
#EOF

    cp -f ${TOPDIR}/caches-single/openssh.cache .

#    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --sysconfdir=${INST_PREFIX}/etc/ssh --with-wolfssl=$INST_PREFIX --disable-strip --with-xauth=/usr/bin/X11/xauth --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=openssh.cache
#    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --sysconfdir=${INST_PREFIX}/etc/ssh --with-ssl-dir=$INST_PREFIX --disable-strip --with-xauth=/usr/bin/X11/xauth --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=openssh.cache
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --sysconfdir=${INST_PREFIX}/etc/ssh --without-openssl --disable-strip --with-xauth=/usr/bin/X11/xauth --x-includes="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/include" --x-libraries="$(${CROSS_PREFIX}-gcc -print-sysroot)/usr/lib" CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=openssh.cache

    make -j $MAKE_TASKS

    make install

    mkdir -p ${INST_PREFIX}/etc/init.d
    cp -f ${TOPDIR}/misc/sshd ${INST_PREFIX}/etc/init.d/
    chmod 755 ${INST_PREFIX}/etc/init.d/sshd
    sed -ie 's/^#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g' ${INST_PREFIX}/etc/ssh/sshd_config

    popd
    touch openssh.installed
fi
}
