build_grep() {
GREP_VERSION=3.12
if ! test -e grep.installed; then
    download https://ftp.gnu.org/gnu/grep/grep-${GREP_VERSION}.tar.xz
    tar xf grep-${GREP_VERSION}.tar.xz
    pushd grep-${GREP_VERSION}
    mkdir -p b
    cd b

    ../configure --prefix=$INST_PREFIX --host=${CROSS_PREFIX} --libdir=$LIBDIR_PREFIX --disable-year2038 --enable-threads=isoc CPPFLAGS="-std=gnu99 -Wno-implicit-function-declaration -I${INST_PREFIX}/include" LDFLAGS="${COMPAT_IRIX_LIB} -L${LIBDIR_PREFIX} -Wl,-rpath-link,${LIBDIR_PREFIX}"

    make -j $MAKE_TASKS

    make install

    popd
    touch grep.installed
fi
}
