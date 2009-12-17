//
//  CurlObject.m
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlObject.h"


@implementation CurlObject

@synthesize delegate;
@synthesize transfer;
@synthesize authUsername;
@synthesize authPassword;

- (id)init
{
	if (self = [super init])
	{
		handle = curl_easy_init();

		if (!handle)
		{
			@throw [NSException exceptionWithName:@"Initialization Error" 
										   reason:@"Unable to initialize libcurl." 
										 userInfo:nil];
		}
		
		curl_easy_setopt(handle, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4); 
		
		[self setDefaultTimeout:15];
	}
	
	return self;
}


- (void)dealloc
{
	curl_global_cleanup();
	
	[super dealloc];
}


- (void)setVerbose:(BOOL)value
{
	if (!handle) return;

	curl_easy_setopt(handle, CURLOPT_VERBOSE, value);
	
	verbose = value;
}


- (BOOL)verbose
{
	return verbose;
}


- (void)setShowProgress:(BOOL)value
{
	if (!handle) return;
	
	if (value) {
		curl_easy_setopt(handle, CURLOPT_NOPROGRESS, 0);
		curl_easy_setopt(handle, CURLOPT_PROGRESSDATA, self);
		curl_easy_setopt(handle, CURLOPT_PROGRESSFUNCTION, handleClientProgress);
	} else {
		curl_easy_setopt(handle, CURLOPT_NOPROGRESS, 1);
		curl_easy_setopt(handle, CURLOPT_PROGRESSDATA, NULL);
		curl_easy_setopt(handle, CURLOPT_PROGRESSFUNCTION, NULL);
	}
	
	showProgress = value;
}


- (BOOL)showProgress
{
	return showProgress;
}


- (long)defaultTimeout
{
	return defaultTimeout;
}


- (void)setDefaultTimeout:(long)value
{
	if (!handle) return;
	
	curl_easy_setopt(handle, CURLOPT_TIMEOUT, value);
	
	defaultTimeout = value;
}


- (void)handleCurlStatus:(CURLcode)status
{
	char *url;
	
	curl_easy_getinfo(handle, CURLINFO_EFFECTIVE_URL, &url); 
	
	switch (status)
	{
		case CURLE_LOGIN_DENIED:
			printf("Invalid login!\n");
			break;
		
		case CURLE_FTP_ACCESS_DENIED:
			printf("Permission denied to %s", url);
			break;
			
		case CURLE_COULDNT_CONNECT:
			printf("Couldn't connect to host '%s' on port %d!\n", [[transfer hostname] UTF8String], [transfer port]);
			break;
			
		case CURLE_COULDNT_RESOLVE_HOST:
			printf("Couldn't resolve host '%s'\n!", [[transfer hostname] UTF8String]);
			break;
			
		case CURLE_RECV_ERROR:
			printf("Failure receiving network data.\n");
			break;
			
	   case CURLE_UNSUPPORTED_PROTOCOL:
			printf("Unknown Protocol '%s'\n!", [[transfer hostname] UTF8String]);
			break;
				   
		default:
			printf("Unhandled Status Code: %d (%s)\n", status, url);
			break;
	}
}


#pragma mark Upload Delegate Methods


- (void)uploadRequiresAuthentication:(id <TransferRecord>)aRecord
{
	if (delegate && [delegate respondsToSelector:@selector(uploadRequiresAuthentication:)])
	{
		[delegate uploadRequiresAuthentication:aRecord];
	}
}


- (void)uploadDidBegin:(id <TransferRecord>)aRecord
{
	if (delegate && [delegate respondsToSelector:@selector(uploadDidBegin:)])
	{
		[delegate uploadDidBegin:aRecord];
	}
}


- (void)uploadDidProgress:(id <TransferRecord>)aRecord toPercent:(int)aPercent
{
	printf("uploadDidProgress:toPercent:%d\n", aPercent);
	
	if (delegate && [delegate respondsToSelector:@selector(uploadDidProgress:toPercent:)])
	{
		[delegate uploadDidProgress:aRecord toPercent:aPercent];
	}
}


- (void)uploadDidFinish:(id <TransferRecord>)aRecord
{
	if (delegate && [delegate respondsToSelector:@selector(uploadDidFinish:)])
	{
		[delegate uploadDidFinish:aRecord];
	}
}


@end


#pragma mark Private Methods


@implementation CurlObject (Private)


static int handleClientProgress(void *clientp, double dltotal, double dlnow, double ultotal, double ulnow)
{	
	CurlObject *client = (CurlObject *)clientp;
	id <TransferRecord>transfer = [client transfer];
	
	int uploadProgress = (ulnow * 100 / ultotal);
	
	[transfer setProgress:uploadProgress];
	
	[client uploadDidProgress:transfer toPercent:uploadProgress];
	
	return 0;
}


@end
