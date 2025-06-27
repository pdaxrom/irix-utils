build_compat_irix() {
if [ "$DISABLE_COMPAT_IRIX_LIB" = "y" ]; then
    COMPAT_IRIX_LIB=""
    COMPAT_IRIX_LIB_STATIC=""
else
    if ! test -e compat_irix.installed; then
	cp -R ${TOPDIR}/compat-irix .
	pushd compat-irix
	make CROSS=${CROSS_PREFIX}- PREFIX=${INST_PREFIX} LIBDIR=${LIBDIR_PREFIX} IRIX_VERSION=${IRIX_VERSION} clean
	make CROSS=${CROSS_PREFIX}- PREFIX=${INST_PREFIX} LIBDIR=${LIBDIR_PREFIX} IRIX_VERSION=${IRIX_VERSION} install

	popd
	touch compat_irix.installed
    fi

    COMPAT_IRIX_LIB="-lcompat_irix"
    COMPAT_IRIX_LIB_STATIC="${LIBDIR_PREFIX}/libcompat_irix.a"
fi
}
