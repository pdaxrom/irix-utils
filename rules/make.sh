build_make() {
if ! test -e make.installed; then
    download https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz
    tar xf make-4.4.1.tar.gz
    pushd make-4.4.1
    mkdir -p b
    cd b
#    cat ${TOPDIR}/caches/*.cache > make.cache

    ac_cv_header_stdbool_h=yes \
    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX CPPFLAGS="-std=gnu99 -I${INST_PREFIX}/include -DNO_GET_LOAD_AVG" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}" --cache-file=make.cache

    make -j $MAKE_TASKS

    make install

    popd
    touch make.installed
fi
}
