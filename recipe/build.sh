#! /bin/bash

set -e

# The zlib check does not let you specify its install prefix so we have
# to go global.
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [ -n "$OSX_ARCH" ] ; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"

    # The -dead_strip_dylibs option breaks g-ir-scanner in this package: the
    # scanner uses the linker to find paths to dylibs, and it wants to find
    # libpoppler.dylib, but with this option the linker strips the library
    # from the test executable. The error message is "ERROR: can't resolve
    # libraries to shared libraries: poppler".
    export LDFLAGS="$(echo $LDFLAGS |sed -e "s/-Wl,-dead_strip_dylibs//g")"
    export LDFLAGS_LD="$(echo $LDFLAGS_LD |sed -e "s/-dead_strip_dylibs//g")"
else
    export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"
fi

mkdir build && cd build

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${target_platform} =~ .*linux.* ]]; then
  # To locate ICONV_INCLUDE_DIR and ICONV_LIBRARIES
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_FIND_ROOT_PATH="${PREFIX};${BUILD_PREFIX}/${HOST}/sysroot")
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES:PATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/include")
fi

# We must avoid very long shebangs here.
echo '#!/usr/bin/env bash' > g-ir-scanner.sh
echo "${PYTHON} ${PREFIX}/bin/g-ir-scanner \$*" >> g-ir-scanner.sh
chmod +x ./g-ir-scanner.sh

cmake -G "$CMAKE_GENERATOR" \
      -D CMAKE_PREFIX_PATH=$PREFIX \
      -D CMAKE_INSTALL_LIBDIR:PATH=$PREFIX/lib \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D ENABLE_XPDF_HEADERS=True \
      -D ENABLE_LIBCURL=True \
      -D ENABLE_LIBOPENJPEG=openjpeg2 \
      -D ENABLE_UNSTABLE_API_ABI_HEADERS=ON \
       $SRC_DIR

make -j$CPU_COUNT V=1
# ctest  # no tests were found :-/
make install -j$CPU_COUNT

pushd ${PREFIX}
  rm -rf lib/libpoppler*.la lib/libpoppler*.a share/gtk-doc
popd
