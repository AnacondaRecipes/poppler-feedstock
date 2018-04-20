#! /bin/bash

set -e

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
