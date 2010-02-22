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
	BOOL usesKeychainForPasswords;
	
	NSOperationQueue *operationQueue;
}

@property(readwrite, assign) id delegate;
@property(readwrite, assign) SecProtocolType protocol;
@property(readwrite, assign) BOOL verbose;
@property(readwrite, assign) BOOL showProgress;
@property(readwrite, assign) BOOL usesKeychainForPasswords;

+ (NSString *)libcurlVersion;

- (CURL *)newHandle;

- (NSString *)getPasswordFromKeychain:(RemoteObject *)object;

@end