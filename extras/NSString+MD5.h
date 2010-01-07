//
//  NSString+MD5.h
//  objective-curl
//
//  Created by nrj on 12/30/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <openssl/md5.h>

@interface NSString (MD5)

/*
 * Create an MD5 hash in the format of XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
 */
+ (NSString *)formattedMD5:(const char *)data length:(unsigned long)len;

@end
