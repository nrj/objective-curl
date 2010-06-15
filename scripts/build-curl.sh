#!/bin/bash

export CFLAGS="-O -g -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5 -arch i386"

CURL_BUILD="curl-7.20.1"

PROJECT_LIBS="/Users/nrj/Code/Cocoa/objective-curl/lib"
PROJECT_INCLUDE="/Users/nrj/Code/Cocoa/objective-curl/include/curl"

tar xzvf $CURL_BUILD.tar.gz

cp $CURL_BUILD.patch $CURL_BUILD

cd $CURL_BUILD

patch -p1 -i $CURL_BUILD.patch

./configure --with-zlib=/usr/lib --with-ssl=/usr/lib --with-libssh2=/usr/local/lib/libssh2 --disable-ldap --disable-ipv6

make

install_name_tool -id @executable_path/../Frameworks/objective-curl.framework/Versions/A/Frameworks/libcurl.4.dylib lib/.libs/libcurl.4.dylib

install_name_tool -change /usr/local/lib/libssh2.1.dylib @executable_path/../Frameworks/objective-curl.framework/Versions/A/Frameworks/libssh2.1.dylib lib/.libs/libcurl.4.dylib

cp lib/.libs/libcurl.4.dylib $PROJECT_LIBS

# cp include/curl/easy.h $PROJECT_INCLUDE
# cp include/curl/multi.h $PROJECT_INCLUDE
# cp include/curl/curl.h $PROJECT_INCLUDE
# cp include/curl/curlbuild.h $PROJECT_INCLUDE
# cp include/curl/curlrules.h $PROJECT_INCLUDE
# cp include/curl/curlver.h $PROJECT_INCLUDE

cd ..

rm -rf $CURL_BUILD