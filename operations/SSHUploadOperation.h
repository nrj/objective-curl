//
//  SSHUploadOperation.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "UploadOperation.h"

@class Upload;

extern NSString * const SFTP_PROTOCOL_PREFIX;

@interface SSHUploadOperation : UploadOperation

static int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, SSHUploadOperation *operation);

- (int)acceptUnknownHostFingerprint:(NSString *)fingerprint forUpload:(Upload *)record;
- (int)acceptMismatchedHostFingerprint:(NSString *)fingerprint forUpload:(Upload *)record;

- (void)showUnknownKeyWarningForHost:(NSString *)hostname;
- (void)showMismatchKeyWarningForHost:(NSString *)hostname;

@end
