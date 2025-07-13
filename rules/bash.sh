build_bash() {
BASH_VERSION=5.2.37
#BASH_VERSION=3.2

if ! test -e bash.installed; then
    download https://ftp.gnu.org/gnu/bash/bash-${BASH_VERSION}.tar.gz
    tar xf bash-${BASH_VERSION}.tar.gz
    pushd bash-${BASH_VERSION}
    test -e ${TOPDIR}/patches/bash-${BASH_VERSION}-irix.diff  && patch -p1 < ${TOPDIR}/patches/bash-${BASH_VERSION}-irix.diff
    mkdir -p build
    cd build
    test -e ${TOPDIR}/caches/bash-${BASH_VERSION}.cache && cp -f ${TOPDIR}/caches/bash-${BASH_VERSION}.cache .
    test -e ${TOPDIR}/caches-single/bash-${BASH_VERSION}.cache && cp -f ${TOPDIR}/caches-single/bash-${BASH_VERSION}.cache .
    ../configure ${EXTRA_CONF_OPTS} --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --without-bash-malloc --with-curses --enable-multibyte --disable-werror CPPFLAGS="-std=gnu99 -D__c99 -I${INST_PREFIX}/include -I${INST_PREFIX}/include/ncurses" LDFLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}" LIBS="${COMPAT_IRIX_LIB_STATIC}" --cache-file=bash-${BASH_VERSION}.cache

    make TERMCAP_LIB=${LIBDIR_PREFIX}/libncurses.a -j $MAKE_TASKS

    make TERMCAP_LIB=${LIBDIR_PREFIX}/libncurses.a install

    popd
    touch bash.installed
fi
}
