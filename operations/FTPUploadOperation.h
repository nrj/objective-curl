//
//  FTPUploadOperation.h
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CurlOperation.h"
#import "CurlClient.h"

@class Upload;

extern NSString * const FTP_PROTOCOL_PREFIX;
extern NSString * const TMP_FILENAME;

@interface FTPUploadOperation : CurlOperation 
{
	Upload *transfer;
}

@property(readwrite, retain) Upload *transfer;

static int handleUploadProgress(FTPUploadOperation *operation, double dltotal, double dlnow, double ultotal, double ulnow);

- (NSArray *)enumerateFilesToUpload:(NSArray *)files;

- (void)handleUploadResult:(CURLcode)result;

- (void)handleUploadFailed:(CURLcode)result;

- (void)performUploadDelegateSelector:(SEL)aSelector withArgument:(id)arg;

- (NSString *)protocolPrefix;

- (NSString *)credentials;

@end
