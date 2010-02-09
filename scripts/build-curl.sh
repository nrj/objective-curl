#!/bin/bash

CURL_BUILD="curl-7.19.7"

PROJECT_LIBS="/Users/nrj/Code/Cocoa/objective-curl/lib"

tar xzvf $CURL_BUILD.tar.gz

cp $CURL_BUILD.patch $CURL_BUILD

cd $CURL_BUILD

patch -p1 -i $CURL_BUILD.patch

./configure --with-zlib=/usr/lib --with-ssl=/usr/lib --with-libssh2=/usr/local/lib/libssh2 --disable-ldap --disable-ipv6

make

install_name_tool -id @executable_path/../Frameworks/objective-curl.framework/Versions/A/Frameworks/libcurl.4.dylib lib/.libs/libcurl.4.dylib

install_name_tool -change /usr/local/lib/libssh2.1.dylib @executable_path/../Frameworks/objective-curl.framework/Versions/A/Frameworks/libssh2.1.dylib lib/.libs/libcurl.4.dylib

cp lib/.libs/libcurl.4.dylib $PROJECT_LIBS

cd ..

rm -rf $CURL_BUILD