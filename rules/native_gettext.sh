build_native_gettext() {
if ! test -e native-gettext.installed; then
    download https://ftp.gnu.org/pub/gnu/gettext/gettext-0.24.tar.gz
    tar xf gettext-0.24.tar.gz
    rm -rf gettext-0.24-host
    mv -f gettext-0.24 gettext-0.24-host
    pushd gettext-0.24-host
    mkdir -p build
    cd build

    ../configure ${EXTRA_CONF_OPTS} --prefix=$HOST_PREFIX

    make -j $MAKE_TASKS

    make install

    popd
    touch native-gettext.installed
fi
}
