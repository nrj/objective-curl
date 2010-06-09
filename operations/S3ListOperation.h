//
//  S3ListOperation.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "CurlOperation.h"

@class RemoteObject;

@interface S3ListOperation : CurlOperation {

	NSString *errorCode;
	NSString *errorMessage;
	
	RemoteObject *request;
}

@property(readwrite, retain) RemoteObject *request;

@property(readwrite, copy) NSString *errorCode;
@property(readwrite, copy) NSString *errorMessage;

static size_t handleResponse(void *ptr, size_t size, size_t nmemb, S3ListOperation *op);

- (void)cancelDependentOperations;

@end
