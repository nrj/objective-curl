//
//  FTPUploadOperation.h
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CurlOperation.h"
#import "UploadClient.h"

@class Upload;

extern NSString * const FTP_PROTOCOL_PREFIX;
extern NSString * const TMP_FILENAME;

@interface FTPUploadOperation : CurlOperation 
{
	Upload *transfer;
	id <UploadClient>client;
}

@property(readwrite, retain) Upload *transfer;
@property(readwrite, assign) id <UploadClient>client;

static int handleUploadProgress(FTPUploadOperation *operation, double dltotal, double dlnow, double ultotal, double ulnow);
static int handleConnecting(CURL *curl, enum curl_connstat status, FTPUploadOperation *operation);

- (id)initWithClient:(id <UploadClient>)aClient transfer:(Upload *)aTransfer;

- (NSArray *)enumerateFilesToUpload:(NSArray *)files;

- (void)handleUploadResult:(CURLcode)result;
- (void)handleUploadFailed:(CURLcode)result;

- (void)performUploadDelegateSelector:(SEL)aSelector withArgument:(id)arg;
- (void)performConnectionDelegateSelector:(SEL)aSelector;

- (NSString *)protocolPrefix;

- (NSString *)credentials;

@end
