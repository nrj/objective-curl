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


extern NSString * const TMP_FILENAME;

@class Upload, PendingTransfer;

@interface FTPUploadOperation : CurlOperation 
{
	Upload *transfer;
}

@property(readwrite, retain) Upload *transfer;

static int handleUploadProgress(FTPUploadOperation *operation, int connected, double dltotal, double dlnow, double ultotal, double ulnow);

- (NSArray *)enumerateFilesToUpload:(NSArray *)files prefix:(NSString *)prefix totalBytes:(double *)totalBytes;

- (void)handleUploadResult:(CURLcode)result;

- (void)handleUploadFailed:(CURLcode)result;

- (void)performUploadDelegateSelector:(SEL)aSelector withArgument:(id)arg;

- (char *)removeTempFileCommand:(NSString *)basePath;

- (NSString *)credentials;

@end
