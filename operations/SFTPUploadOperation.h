//
//  SFTPUploadOperation.h
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FTPUploadOperation.h"

extern NSString * const SFTP_PROTOCOL_PREFIX;

@interface SFTPUploadOperation : FTPUploadOperation

static int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, Upload *transfer);

@end
