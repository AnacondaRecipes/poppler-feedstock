#! /bin/bash

set -e

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

# We must avoid very long shebangs here.
echo '#!/usr/bin/env bash' > g-ir-scanner.sh
echo "${PYTHON} ${PREFIX}/bin/g-ir-scanner \$*" >> g-ir-scanner.sh
chmod +x ./g-ir-scanner.sh

cmake -GNinja \
      ${CMAKE_ARGS} \
      -D ENABLE_LIBCURL=True \
      -D ENABLE_LIBOPENJPEG=openjpeg2 \
      -D ENABLE_UNSTABLE_API_ABI_HEADERS=ON \
       $SRC_DIR

cmake --build .
# ctest  # no tests were found :-/
cmake --install .

pushd ${PREFIX}
  rm -rf lib/libpoppler*.la lib/libpoppler*.a share/gtk-doc
popd
