//
//  CurlSFTP.h
//  objective-curl
//
//  Created by nrj on 12/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CurlFTP.h"
#import "TransferStatus.h"
#import "NSString+MD5.h"


extern const int DEFAULT_SFTP_PORT;
extern const NSString * DEFAULT_KNOWN_HOSTS;

@interface CurlSFTP : CurlFTP
{
	NSString *knownHostsFile;
	
	NSMutableDictionary *hostKeyFingerprints;
}

static int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, CurlSFTP *client);

- (void)setKnownHostsFile:(NSString *)filePath;
- (NSString *)knownHostsFile;

- (int)handleUnknownHostKey:(NSString *)rsaFingerprint;
- (int)handleMismatchedHostKey:(NSString *)rsaFingerprint;

- (void)acceptHostKeyFingerprint:(NSString *)fingerprint permanently:(BOOL)permanent;
- (void)rejectHostKeyFingerprint:(NSString *)fingerprint;

@end
