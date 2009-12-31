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


@interface CurlObject : NSObject
{	
	id delegate;

	SecProtocolType protocolType;
	
	BOOL verbose;
	BOOL showProgress;
	BOOL isUploading;
	
	NSString *authUsername;
	NSString *authPassword;
	
	id <TransferRecord> transfer;
	
	CURL *handle;
}

@property(readwrite, assign) id delegate;
@property(readwrite, assign) SecProtocolType protocolType;
@property(readwrite, copy) NSString *authUsername;
@property(readwrite, copy) NSString *authPassword;
@property(readwrite, assign) id <TransferRecord> transfer;
@property(readwrite, assign) BOOL isUploading;

+ (NSString *)libcurlVersion;

- (CURL *)handle;

- (void)setVerbose:(BOOL)value;

- (BOOL)verbose;

- (void)setShowProgress:(BOOL)value;

- (BOOL)showProgress;

- (BOOL)hasAuthUsername;

- (BOOL)hasAuthPassword;

- (NSString * const)protocolPrefix;

static int handleCurlProgress(CurlObject *client, double dltotal, double dlnow, double ultotal, double ulnow);

- (void)handleCurlResult:(CURLcode)result;

- (void)performDelegateSelector:(SEL)aSelector;

@end