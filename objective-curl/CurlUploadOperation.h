//
//  UploadOperation.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "CurlOperation.h"
#import "CurlClient.h"


@class CurlUpload, CurlFileTransfer;


@interface CurlUploadOperation : CurlOperation 
{
	CurlUpload *upload;
}

@property(readwrite, retain) CurlUpload *upload;

static int handleUploadProgress(CurlUploadOperation *operation, int connected, double dltotal, double dlnow, double ultotal, double ulnow);

-(BOOL)dependentOperationCancelled;

- (void)calculateUploadProgress:(double)ulnow total:(double)ultotal;

- (void)setProtocolSpecificOptions;

- (void)setFileSpecificOptions:(CurlFileTransfer *)file;

- (NSString *)urlForTransfer:(CurlFileTransfer *)file;

- (NSArray *)enumerateFilesToUpload:(NSArray *)files prefix:(NSString *)prefix totalBytes:(double *)totalBytes;

- (void)handleUploadResult:(CURLcode)result;

- (void)handleUploadFailed:(CURLcode)result;

- (void)notifyDelegateOfFailure;

- (void)performDelegateSelector:(SEL)aSelector withArgument:(id)arg;

- (NSString *)credentials;

- (void)startByteTimer;

- (void)enterByteTimerThread;

- (void)calculateBytesPerSecond:(NSTimer *)timer;

@end
