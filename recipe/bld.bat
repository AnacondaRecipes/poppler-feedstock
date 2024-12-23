mkdir build
cd build

:: Remove /GL from CXXFLAGS as this causes an error with the 
:: cmake 'export all symbols' functionality
set "CXXFLAGS= -MD"
cmd /K "exit /B 0"
cmake -G "Ninja" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_LIBDIR:PATH=%LIBRARY_LIB% ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D ENABLE_UNSTABLE_API_ABI_HEADERS=True ^
      -D ENABLE_GPGME=OFF ^
      -D ENABLE_LIBCURL=True ^
      -D ENABLE_LIBOPENJPEG=openjpeg2 ^
      -D ENABLE_NSS3=OFF ^
      -D ENABLE_QT6=OFF ^
      -D GLIB2_MKENUMS_PYTHON=%PYTHON% ^
       %SRC_DIR%
if errorlevel 1 (
  type CMakeFiles\CMakeOutput.log
  exit /b 1
)
exit /b 0
