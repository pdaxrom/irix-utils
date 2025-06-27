build_unzip() {
UNZIP_VERSION=60
if ! test -e unzip.installed; then
    download https://sourceforge.net/projects/infozip/files/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip${UNZIP_VERSION}.tar.gz
    tar xf unzip${UNZIP_VERSION}.tar.gz
    pushd unzip${UNZIP_VERSION}

    make -j $MAKE_TASKS -f unix/Makefile generic CC="${CROSS_PREFIX}-gcc -std=gnu89"

    make prefix=$INST_PREFIX MANDIR=${INST_PREFIX}/share/man/man1 -f unix/Makefile install

    popd
    touch unzip.installed
fi
}
