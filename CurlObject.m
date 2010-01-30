//
//  CurlObject.m
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlObject.h"
#import "TransferStatus.h"


@implementation CurlObject

@synthesize delegate;
@synthesize protocolType;

@synthesize authUsername;
@synthesize authPassword;

@synthesize verbose;
@synthesize showProgress;


/*
 * Returns a string containing the version info of libcurl that the framework is using. 
 *
 *      Currently "libcurl/7.19.7 OpenSSL/0.9.7l zlib/1.2.3 libssh2/1.2.1"
 */
+ (NSString *)libcurlVersion
{		
	return [NSString stringWithCString:curl_version()];
}


/*
 * Initialize the operation queue, and other property defaults.
 */
- (id)init
{
	if (self = [super init])
	{
		operationQueue = [[NSOperationQueue alloc] init];
		
		[self setAuthUsername:@""];
		[self setAuthPassword:@""];
	}
	
	return self;
}


/*
 * Cleanup. 
 */
- (void)dealloc
{
	[operationQueue release], operationQueue = nil;
	
	[authUsername release], authUsername = nil;
	[authPassword release], authPassword = nil;
	
	[super dealloc];
}


/*
 * Generates a new curl_easy_handle.
 *
 *      See http://curl.haxx.se/libcurl/c/libcurl-easy.html
 */
- (CURL *)newHandle
{
	CURL *handle = curl_easy_init();
	
	curl_easy_setopt(handle, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_WHATEVER);
	curl_easy_setopt(handle, CURLOPT_VERBOSE, [self verbose]);
	curl_easy_setopt(handle, CURLOPT_NOPROGRESS, ![self showProgress]);
	
	return handle;
}


/*
 * Convenience function... do we have a username set for auth?
 */
- (BOOL)hasAuthUsername
{
	return (authUsername != NULL && ![authUsername isEqualToString:@""]);
}


/*
 * Convenience function... do we have a password set for auth?
 */
- (BOOL)hasAuthPassword
{
	return (authPassword != NULL && ![authPassword isEqualToString:@""]);
}


@end