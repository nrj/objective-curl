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

	BOOL verbose;
	BOOL showProgress;
	BOOL isUploading;
	
	NSString *authUsername;
	NSString *authPassword;
	
	id <TransferRecord> transfer;
	
	CURL *handle;
}

@property(readwrite, assign) id delegate;

@property(readwrite, assign) BOOL verbose;
@property(readwrite, assign) BOOL showProgress;
@property(readwrite, assign) BOOL isUploading;

@property(readwrite, copy) NSString *authUsername;
@property(readwrite, copy) NSString *authPassword;

@property(readwrite, assign) id <TransferRecord> transfer;

- (CURL *)handle;

- (void)handleCurlResult:(CURLcode)result;

- (BOOL)hasAuthUsername;
- (BOOL)hasAuthPassword;

- (void)performDelegateSelector:(SEL)aSelector;

@end