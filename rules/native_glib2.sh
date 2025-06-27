build_native_glib2() {
if ! test -e native-glib2.installed; then
    download https://download.gnome.org/sources/glib/2.20/glib-2.20.5.tar.gz
    tar xf glib-2.20.5.tar.gz
    rm -rf glib-2.20.5-native
    mv -f glib-2.20.5 glib-2.20.5-native
    pushd glib-2.20.5-native
    mkdir -p b2
    cd b2

    ../configure --prefix=$HOST_PREFIX

    make -j $MAKE_TASKS

    make install

    popd
    touch native-glib2.installed
fi
}
