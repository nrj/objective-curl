//
//  UploadOperation.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "CurlOperation.h"
#import "CurlClient.h"


@class Upload, FileTransfer;


@interface UploadOperation : CurlOperation 
{
	Upload *upload;
}

@property(readwrite, retain) Upload *upload;

static int handleUploadProgress(UploadOperation *operation, int connected, double dltotal, double dlnow, double ultotal, double ulnow);

-(BOOL)dependentOperationCancelled;

- (void)calculateUploadProgress:(double)ulnow total:(double)ultotal;

- (void)setProtocolSpecificOptions;

- (void)setFileSpecificOptions:(FileTransfer *)file;

- (NSString *)urlForTransfer:(FileTransfer *)file;

- (NSArray *)enumerateFilesToUpload:(NSArray *)files prefix:(NSString *)prefix totalBytes:(double *)totalBytes;

- (void)handleUploadResult:(CURLcode)result;

- (void)handleUploadFailed:(CURLcode)result;

- (void)performUploadDelegateSelector:(SEL)aSelector withArgument:(id)arg;

- (NSString *)credentials;

- (void)startByteTimer;

- (void)enterByteTimerThread;

- (void)calculateBytesPerSecond:(NSTimer *)timer;

@end
