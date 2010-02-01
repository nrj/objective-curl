//
//  SFTPUploadOperation.h
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FTPUploadOperation.h"
#import "SSHDelegate.h"


extern NSString * const SFTP_PROTOCOL_PREFIX;

@interface SFTPUploadOperation : FTPUploadOperation <SSHDelegate>

static int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, SFTPUploadOperation *operation);

- (int)acceptUnknownFingerprint:(NSString *)fingerprint forHost:(NSString *)hostname;
- (int)acceptMismatchedFingerprint:(NSString *)fingerprint forHost:(NSString *)hostname;

- (void)showUnknownKeyWarningForHost:(NSString *)hostname;
- (void)showMismatchKeyWarningForHost:(NSString *)hostname;

@end
