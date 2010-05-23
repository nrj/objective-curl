//
//  UploadOperation.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "CurlOperation.h"
#import "CurlClient.h"


extern NSString * const TMP_FILENAME;

@class Upload, FileTransfer;

@interface UploadOperation : CurlOperation 
{
	Upload *upload;
}

@property(readwrite, retain) Upload *upload;

static int handleUploadProgress(UploadOperation *operation, int connected, double dltotal, double dlnow, double ultotal, double ulnow);

- (void)setAuthOptions;

- (void)setFileSpecificOptions:(FileTransfer *)file;

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
