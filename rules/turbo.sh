build_turbo() {
    local PKG=turbo
    local PKG_VERSION=
    local PKG_EXT=
    local PKG_SUBVERSION=
    local PKG_URL="https://github.com/magiblot/turbo.git"
    local PKG_DESC="Turbo is an experimental text editor for the terminal, based on the Scintilla code editing component by Neil Hodgson and the Turbo Vision application framework."
    local PKG_DEPS=""
    local PKG_PATCH="patches/turbo-irix.diff"
    if ! test -e turbo.installed; then
        git clone --recursive ${PKG_URL}
        pushd ${PKG}
            apply_patch ${PKG_PATCH}

            mkdir -p buildx
            cd buildx
            cmake -DCMAKE_TOOLCHAIN_FILE=${CMAKE_CROSS_CONF} .. -DCMAKE_LIBRARY_PATH=${LIBDIR_PREFIX} -DNCURSESW=${LIBDIR_PREFIX}/libncursesw.so -DNCURSESW_INCLUDE=${INST_PREFIX}/include -DCMAKE_CXX_FLAGS="-O3 -I${INST_PREFIX}/include" -DCMAKE_EXE_LINKER_FLAGS="-L${LIBDIR_PREFIX} -Wl,-rpath,${LIBDIR_PREFIX}:${LIBSTDCPP_PREFIX} -lcompat_irix"

            make -j $MAKE_TASKS

            ${CROSS_PREFIX}-strip turbo
            cp -f turbo ${INST_PREFIX}/bin/turbo
        popd
        touch turbo.installed
    fi
}
