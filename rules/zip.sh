build_zip() {
ZIP_VERSION=30
if ! test -e zip.installed; then
    download https://downloads.sourceforge.net/infozip/zip${ZIP_VERSION}.tar.gz
    tar xf zip${ZIP_VERSION}.tar.gz
    pushd zip${ZIP_VERSION}

    make -j $MAKE_TASKS -f unix/Makefile generic CC="${CROSS_PREFIX}-gcc -std=gnu89"

    make prefix=$INST_PREFIX MANDIR=${INST_PREFIX}/share/man/man1 -f unix/Makefile install

    popd
    touch zip.installed
fi
}
