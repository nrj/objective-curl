/*!
    @header NSString+MD5.h
    @abstract Category methods for creating MD5 hashes as strings.
    @discussion Category methods for creating MD5 hashes as strings.
*/


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
