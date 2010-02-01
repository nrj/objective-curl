//
//  NSString+MD5.h
//  objective-curl
//
//  Created by nrj on 12/30/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <openssl/md5.h>
#include <openssl/evp.h>
#include <openssl/bio.h>


@interface NSString (MD5)

/*
 * Create an MD5 hash in the format of XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
 */
+ (NSString *)formattedMD5:(const char *)data length:(unsigned long)len;

/*
 * Same as above, but takes in the Base64 encoded data found in the ~/.ssh/known_hosts file.
 */
+ (NSString *)formattedMD5FromBase64:(const char *)data length:(unsigned long)len;

@end
