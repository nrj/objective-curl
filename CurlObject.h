//
//  CurlObject.h
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/stat.h>
#include <curl/curl.h>

@class RemoteObject;

@interface CurlObject : NSObject
{	
	id delegate;

	SecProtocolType protocol;
	
	BOOL verbose;
	BOOL showProgress;
	
	NSOperationQueue *operationQueue;
}

@property(readwrite, assign) id delegate;
@property(readwrite, assign) SecProtocolType protocol;
@property(readwrite, assign) BOOL verbose;
@property(readwrite, assign) BOOL showProgress;

+ (NSString *)libcurlVersion;

- (CURL *)newHandle;

@end