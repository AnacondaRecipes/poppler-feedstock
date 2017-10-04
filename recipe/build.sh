#! /bin/bash

set -e

# The zlib check does not let you specify its install prefix so we have
# to go global.
<<<<<<< HEAD
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
=======
>>>>>>> Add cross-compilation support
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
if [[ ${HOST} =~ .*darwin.* ]] ; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
fi

<<<<<<< HEAD
mkdir build && cd build

cmake -G "$CMAKE_GENERATOR" \
      -D CMAKE_PREFIX_PATH=$PREFIX \
      -D CMAKE_INSTALL_LIBDIR:PATH=$PREFIX/lib \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D ENABLE_XPDF_HEADERS=True \
      -D ENABLE_LIBCURL=True \
      -D ENABLE_LIBOPENJPEG=openjpeg2 \
       $SRC_DIR

make -j$CPU_COUNT
# ctest  # no tests were found :-/
make install -j$CPU_COUNT
=======
configure_args=(
    --prefix=${PREFIX}
    --disable-dependency-tracking
    --enable-xpdf-headers
    --enable-libcurl
    --enable-introspection=auto
    --disable-gtk-doc
    --disable-gtk-test
)


./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j${CPU_COUNT} ${VERBOSE_AT}
# make check requires a big data download
make install
>>>>>>> Add cross-compilation support

pushd ${PREFIX}
  rm -rf lib/libpoppler*.la lib/libpoppler*.a share/gtk-doc
popd
