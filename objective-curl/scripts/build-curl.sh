#!/bin/bash

OSX_SDK_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs"
export CFLAGS="-O -g -isysroot $OSX_SDK_PATH/MacOSX10.7.sdk -mmacosx-version-min=10.7"
export CPPFLAGS="-I/usr/local/include -I/usr/include"
export LDFLAGS="-L/usr/local/lib -L/usr/lib"

CURL_BUILD="curl-7.30.0"

if [ -d $CURL_BUILD ]; then
   rm -rf $CURL_BUILD
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_LIBS="$SCRIPT_DIR/../dylib"
PROJECT_INCLUDE="$SCRIPT_DIR/../include"

# Extract libcurl source
tar xzvf $CURL_BUILD.tar.gz
cp $CURL_BUILD.patch $CURL_BUILD

# Change to the source dir
cd $CURL_BUILD

# Apply our patch
patch -p1 -i $CURL_BUILD.patch

# Build libcurl
./configure --disable-ldap \
            --disable-ipv6 \
            --disable-imap \
            --disable-pop3 \
            --disable-smtp \
            --disable-smtps \
            --disable-gopher \
            --disable-rtsp \
            --disable-rtmp \
            --disable-telnet
make

# Change the identification path of libcurl and the load path for libssh2
CURL_DYLIB_PATH="lib/.libs/libcurl.4.dylib"
install_name_tool -id @executable_path/../Frameworks/objective-curl.framework/Versions/A/Frameworks/libcurl.4.dylib $CURL_DYLIB_PATH
install_name_tool -change /usr/local/lib/libssh2.1.dylib @executable_path/../Frameworks/objective-curl.framework/Versions/A/Frameworks/libssh2.1.dylib $CURL_DYLIB_PATH

# Copy libcurl to our project directory
echo "Copying $CURL_DYLIB_PATH => $PROJECT_LIBS"
cp $CURL_DYLIB_PATH $PROJECT_LIBS

# Cleanup
cd ..
echo "Removing directory $CURL_BUILD"
rm -rf $CURL_BUILD