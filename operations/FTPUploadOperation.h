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

@class Upload;

@interface FTPUploadOperation : CurlOperation 
{
	Upload *upload;
}

@property(readwrite, retain) Upload *upload;

static int handleUploadProgress(FTPUploadOperation *operation, int connected, double dltotal, double dlnow, double ultotal, double ulnow);

- (NSArray *)enumerateFilesToUpload:(NSArray *)files prefix:(NSString *)prefix totalBytes:(double *)totalBytes;

- (void)handleUploadResult:(CURLcode)result;

- (void)handleUploadFailed:(CURLcode)result;

- (void)performUploadDelegateSelector:(SEL)aSelector withArgument:(id)arg;

- (char *)removeTempFileCommand:(NSString *)basePath;

- (NSString *)credentials;

- (void)startByteTimer;

- (void)enterByteTimerThread;

- (void)calculateBytesPerSecond:(NSTimer *)timer;

@end
