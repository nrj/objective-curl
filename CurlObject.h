//
//  CurlObject.h
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <curl/curl.h>
#include <sys/stat.h>


@interface CurlObject : NSObject
{	
	id delegate;

	SecProtocolType protocolType;
	
	BOOL verbose;
	BOOL showProgress;
		
	NSOperationQueue *operationQueue;
}

@property(readwrite, assign) id delegate;
@property(readwrite, assign) SecProtocolType protocolType;
@property(readwrite, assign) BOOL verbose;
@property(readwrite, assign) BOOL showProgress;

+ (NSString *)libcurlVersion;

- (CURL *)newHandle;

@end