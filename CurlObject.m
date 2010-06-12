//
//  CurlObject.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "CurlObject.h"
#import "RemoteObject.h"


@implementation CurlObject


@synthesize delegate;

@synthesize protocol;

@synthesize verbose;

@synthesize showProgress;


/*
 * Returns a string containing the version info of libcurl that the framework is using. 
 *
 *      Currently "libcurl/7.19.7 OpenSSL/0.9.7l zlib/1.2.3 libssh2/1.2.1"
 */
+ (NSString *)libcurlVersion
{		
	return [NSString stringWithUTF8String:curl_version()];
}


/*
 * Initialize the operation queue, and other property defaults.
 */
- (id)init
{
	if (self = [super init])
	{
		operationQueue = [[NSOperationQueue alloc] init];
	}
	
	return self;
}


/*
 * Cleanup. 
 */
- (void)dealloc
{
	[operationQueue release], operationQueue = nil;
		
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


- (int)clientType
{
	// Abstract
	
	return -1;
}

@end