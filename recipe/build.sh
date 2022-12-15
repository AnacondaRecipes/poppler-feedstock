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

    # See: https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ ${target_platform} == linux-ppc64le ]]; then
  # there are issues with CDTs and there HOST name ...
  pushd "${BUILD_PREFIX}"
  cp -Rn powerpc64le-conda_cos7-linux-gnu/* powerpc64le-conda-linux-gnu/.
  popd
  export CFLAGS="${CFLAGS} -Wno-enum-conversion"
fi

mkdir -p build
cd build

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$BUILD_PREFIX/lib/pkgconfig"

cmake ${CMAKE_ARGS} ${EXTRA_CMAKE_ARGS} \
    -GNinja \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    $SRC_DIR

ninja
# ctest  # no tests were found :-/
