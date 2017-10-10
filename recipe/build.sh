#! /bin/bash

set -e

# The zlib check does not let you specify its install prefix so we have
# to go global.
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
if [[ ${HOST} =~ .*darwin.* ]] ; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
fi

mkdir build
cd build

cmake -G "$CMAKE_GENERATOR" \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DENABLE_XPDF_HEADERS=True \
      -DENABLE_LIBCURL=True \
      -DENABLE_LIBOPENJPEG=openjpeg2 \
      ..

make -j${CPU_COUNT} ${VERBOSE_CM}
# make check requires a big data download
make install

pushd ${PREFIX}
  rm -rf lib/libpoppler*.la lib/libpoppler*.a share/gtk-doc
popd
