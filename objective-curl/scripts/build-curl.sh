#!/bin/bash

OSX_SDK_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk"
export CFLAGS="-O -g -isysroot $OSX_SDK_PATH -mmacosx-version-min=10.7 -arch x86_64"

CURL_BUILD="curl-7.30.0"

if [ -d $CURL_BUILD ]; then
   rm -rf $CURL_BUILD
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PROJECT_LIBS="$SCRIPT_DIR/../lib"
PROJECT_INCLUDE="$SCRIPT_DIR/../include"

export CPPFLAGS="-I$PROJECT_INCLUDE"
export LDFLAGS="-L$PROJECT_LIBS"
export LIBS="-lssh2 -lssl -lz"

# Extract libcurl source
tar xzvf $CURL_BUILD.tar.gz
cp $CURL_BUILD.patch $CURL_BUILD

# Change to the source dir
cd $CURL_BUILD

# Apply our patch
patch -p1 -i $CURL_BUILD.patch

# Build libcurl
./configure --enable-static \
            --disable-shared \
            --disable-ldap \
            --with-libssh2
make

# Copy the static lib into the project
CURL_STATIC_LIB_PATH="lib/.libs/libcurl.a"
echo "Copying $CURL_STATIC_LIB_PATH => $PROJECT_LIBS"
cp $CURL_STATIC_LIB_PATH $PROJECT_LIBS

# Cleanup
cd ..
echo "Removing directory $CURL_BUILD"
# rm -rf $CURL_BUILD