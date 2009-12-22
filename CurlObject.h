//
//  CurlObject.h
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransferRecord.h"

#include <stdio.h>
#include <string.h>
#include <curl/curl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

#define DEFAULT_MAX_CONNECTS 1

@interface CurlObject : NSObject
{	
	id delegate;
	CURL *handle;

	BOOL verbose;
	BOOL showProgress;
	
	long defaultTimeout;
	
	NSString *authUsername;
	NSString *authPassword;
	
	id <TransferRecord> transfer;
	
	BOOL isUploading;
}

@property(readwrite, assign) id delegate;
@property(readwrite, assign) id <TransferRecord> transfer;
@property(readwrite, copy) NSString *authUsername;
@property(readwrite, copy) NSString *authPassword;
@property(readwrite, assign) BOOL isUploading;

- (BOOL)verbose;
- (void)setVerbose:(BOOL)value;

- (BOOL)showProgress;
- (void)setShowProgress:(BOOL)value;

- (long)defaultTimeout;
- (void)setDefaultTimeout:(long)value;

- (void)handleCurlResult:(CURLcode)result;

- (BOOL)hasAuthUsername;
- (BOOL)hasAuthPassword;

- (void)performDelegateSelector:(SEL)aSelector;

@end