//
//  SSHUploadOperation.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "CurlUploadOperation.h"

@class CurlUpload;

extern NSString * const SFTP_PROTOCOL_PREFIX;

@interface CurlSSHUploadOperation : CurlUploadOperation

static int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, CurlSSHUploadOperation *operation);

- (int)acceptUnknownHostFingerprint:(NSString *)fingerprint forUpload:(CurlUpload *)record;
- (int)acceptMismatchedHostFingerprint:(NSString *)fingerprint forUpload:(CurlUpload *)record;

- (void)showUnknownKeyWarningForHost:(NSString *)hostname;
- (void)showMismatchKeyWarningForHost:(NSString *)hostname;

@end
