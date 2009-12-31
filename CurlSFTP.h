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


#define DEFAULT_SFTP_PORT 22

@interface CurlSFTP : CurlFTP
{
	NSString *knownHostsFile;
	NSMutableDictionary *acceptedHostKeys;
}

int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, void *client);

- (void)setKnownHostsFile:(NSString *)filePath;
- (NSString *)knownHostsFile;

- (void)addAcceptedHostKey:(NSString *)hostKey;
- (void)addAcceptedHostKey:(NSString *)hostKey toFile:(BOOL)addToFile;

@end
