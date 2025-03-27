#! /bin/bash

set -e

# Ensure we look in the correct directory for gir files
export XDG_DATA_DIRS="$PREFIX/share"

export EXTRA_CMAKE_ARGS="-GNinja -DCMAKE_INSTALL_LIBDIR=lib -DENABLE_UNSTABLE_API_ABI_HEADERS=ON -DENABLE_GPGME=OFF -DENABLE_LIBCURL=ON -DENABLE_LIBOPENJPEG=openjpeg2 -DENABLE_QT6=OFF"

if [ -n "$OSX_ARCH" ] ; then
    # The -dead_strip_dylibs option breaks g-ir-scanner in this package: the
    # scanner uses the linker to find paths to dylibs, and it wants to find
    # libpoppler.dylib, but with this option the linker strips the library
    # from the test executable. The error message is "ERROR: can't resolve
    # libraries to shared libraries: poppler".
    export LDFLAGS="$(echo $LDFLAGS |sed -e "s/-Wl,-dead_strip_dylibs//g")"
    export LDFLAGS_LD="$(echo $LDFLAGS_LD |sed -e "s/-dead_strip_dylibs//g")"

    # See: https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ ${target_platform} == linux-ppc64le ]]; then
  # there are issues with CDTs and there HOST name ...
  pushd "${BUILD_PREFIX}"
  cp -Rn powerpc64le-conda-linux-gnu/* powerpc64le-conda_cos7-linux-gnu/. || true
  cp -Rn powerpc64le-conda_cos7-linux-gnu/* powerpc64le-conda-linux-gnu/. || true
  popd
  export CFLAGS="${CFLAGS} -Wno-enum-conversion -Wno-maybe-uninitialized -fno-lto"
  export CXXFLAGS="${CXXFLAGS} -Wno-enum-conversion -Wno-maybe-uninitialized -fno-lto"
fi

mkdir -p build
cd build

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$BUILD_PREFIX/lib/pkgconfig"

cmake ${CMAKE_ARGS} ${EXTRA_CMAKE_ARGS} \
    -GNinja \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DTESTDATADIR=$SRC_DIR/test_suite \
    -DENABLE_QT6=ON \
    -DENABLE_QT5=OFF \
    $SRC_DIR

ninja
# ctest  # no tests were found :-/

ninja test
