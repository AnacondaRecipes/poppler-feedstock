#! /bin/bash

set -e

export EXTRA_CMAKE_ARGS="-GNinja -DCMAKE_INSTALL_LIBDIR=lib -DENABLE_UNSTABLE_API_ABI_HEADERS=ON -DENABLE_LIBCURL=ON -DENABLE_LIBOPENJPEG=openjpeg2"

if [ -n "$OSX_ARCH" ] ; then
    # The -dead_strip_dylibs option breaks g-ir-scanner in this package: the
    # scanner uses the linker to find paths to dylibs, and it wants to find
    # libpoppler.dylib, but with this option the linker strips the library
    # from the test executable. The error message is "ERROR: can't resolve
    # libraries to shared libraries: poppler".
    export LDFLAGS="$(echo $LDFLAGS |sed -e "s/-Wl,-dead_strip_dylibs//g")"
    export LDFLAGS_LD="$(echo $LDFLAGS_LD |sed -e "s/-dead_strip_dylibs//g")"
fi

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$BUILD_PREFIX/lib/pkgconfig"

cd build
ninja install

rm -rf ${PREFIX}/lib/libpoppler*.la ${PREFIX}/lib/libpoppler*.a ${PREFIX}/share/gtk-doc

if [[ "$PKG_NAME" == poppler ]]
then
    rm -rf ${PREFIX}/include/poppler/qt5
    rm -rf ${PREFIX}/lib/libpoppler-qt5.*
    rm -rf ${PREFIX}/lib/pkgconfig/poppler-qt5.pc
fi

if [[ "$PKG_NAME" == poppler-qt ]]
then
    rm -f ${PREFIX}/bin/pdf*
    rm -f ${PREFIX}/include/poppler/*.h
    rm -rf ${PREFIX}/include/poppler/cpp
    rm -rf ${PREFIX}/include/poppler/fofi
    rm -rf ${PREFIX}/include/poppler/glib
    rm -rf ${PREFIX}/include/poppler/goo
    rm -rf ${PREFIX}/include/poppler/splash
    rm -f ${PREFIX}/lib/girepository-1.0/Poppler-*.typelib
    rm -f ${PREFIX}/lib/libpoppler.*
    rm -f ${PREFIX}/lib/libpoppler-cpp.*
    rm -f ${PREFIX}/lib/libpoppler-glib.*
    rm -f ${PREFIX}/lib/pkgconfig/poppler.pc
    rm -f ${PREFIX}/lib/pkgconfig/poppler-cpp.pc
    rm -f ${PREFIX}/lib/pkgconfig/poppler-glib.pc
    rm -f ${PREFIX}/share/gir-1.0/Poppler-*.gir
    rm -f ${PREFIX}/share/man/man1/pdf*
fi
