//
//  S3UploadOperation.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "UploadOperation.h"


@interface S3UploadOperation : UploadOperation {
	
	NSString *errorCode;
	NSString *errorMessage;
	
}

@property(readwrite, copy) NSString *errorCode;
@property(readwrite, copy) NSString *errorMessage;

static size_t writeFunction(void *ptr, size_t size, size_t nmemb, void *data);


@end
