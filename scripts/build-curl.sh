#!/bin/bash

PROJECT_LIBS=/Users/nrj/Code/Cocoa/objective-curl/lib

make clean

if [ "$1" == "-c" ]; then
	./configure --with-zlib=/usr/lib --with-ssl=/usr/lib --with-libssh2=/usr/local/lib/libssh2 --disable-ldap --disable-ipv6
fi

make

install_name_tool -id @executable_path/../Frameworks/objective-curl.framework/Versions/A/Frameworks/libcurl.4.dylib lib/.libs/libcurl.4.dylib
install_name_tool -change /usr/local/lib/libssh2.1.dylib @executable_path/../Frameworks/objective-curl.framework/Versions/A/Frameworks/libssh2.1.dylib lib/.libs/libcurl.4.dylib

cp lib/.libs/libcurl.4.dylib $PROJECT_LIBS