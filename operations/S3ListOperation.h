//
//  S3ListOperation.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "CurlOperation.h"


struct ResultStruct {
	char *buffer;
	size_t size;
};


@class RemoteObject;


@interface S3ListOperation : CurlOperation {
	
	RemoteObject *request;
}


@property(readwrite, retain) RemoteObject *request;


static size_t handleS3BucketListProgress(S3ListOperation *operation, int connected, double dltotal, double dlnow, double ultotal, double ulnow);

static size_t handleS3BucketList(void *ptr, size_t size, size_t nmemb, void *data);


- (void)setupCurl;

- (void)handleS3BucketListResult:(CURLcode)result body:(NSString *)xml;

- (void)handleS3BucketListFailed:(CURLcode)result error:(NSDictionary *)s3error;

- (void)performDelegateSelector:(SEL)aSelector;

@end
