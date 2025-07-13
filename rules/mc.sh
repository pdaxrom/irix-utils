build_mc() {
    local MC_VERSION=4.8.12
    if ! test -e mc.installed; then
	download https://ftp.osuosl.org/pub/midnightcommander/mc-${MC_VERSION}.tar.bz2
	tar xf mc-${MC_VERSION}.tar.bz2
	pushd mc-${MC_VERSION}
	    patch -p1 < ${TOPDIR}/patches/mc-${MC_VERSION}-irix.diff
	    mkdir -p b
	    cd b
#	    cp ${TOPDIR}/caches-single/mc.cache .

	    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --disable-nls --without-included-gettext --with-screen=ncurses --with-x --with-ncurses-includes=${INST_PREFIX}/include --with-ncurses-libs=${LIBDIR_PREFIX} CPPFLAGS="-Wno-implicit-int -std=gnu99 -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" --cache-file=mc.cache

	    make -j $MAKE_TASKS

	    make install
	popd
	touch mc.installed
    fi
}
