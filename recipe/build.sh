#! /bin/bash

set -e

# The zlib check does not let you specify its install prefix so we have
# to go global.
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
if [[ ${HOST} =~ .*darwin.* ]] ; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
fi

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

pushd ${PREFIX}
  rm -rf lib/libpoppler*.la lib/libpoppler*.a share/gtk-doc
popd
