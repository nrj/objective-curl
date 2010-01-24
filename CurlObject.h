//
//  CurlObject.h
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteObject.h"
#include <curl/curl.h>
#include <sys/stat.h>


@interface CurlObject : NSObject
{	
	id delegate;

	SecProtocolType protocolType;
	
	BOOL verbose;
	BOOL showProgress;
	BOOL isUploading;
	BOOL isDownloading;
	
	NSString *authUsername;
	NSString *authPassword;
	
	NSOperationQueue *operationQueue;
}

@property(readwrite, assign) id delegate;
@property(readwrite, assign) SecProtocolType protocolType;
@property(readwrite, copy) NSString *authUsername;
@property(readwrite, copy) NSString *authPassword;
@property(readwrite, assign) BOOL verbose;
@property(readwrite, assign) BOOL showProgress;
@property(readwrite, assign) BOOL isUploading;
@property(readwrite, assign) BOOL isDownloading;

+ (NSString *)libcurlVersion;

- (CURL *)newHandle;

- (BOOL)hasAuthUsername;

- (BOOL)hasAuthPassword;

- (NSString * const)protocolPrefix;

- (void)handleCurlResult:(CURLcode)result forObject:(RemoteObject *)task;

@end