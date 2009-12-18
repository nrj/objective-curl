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
@synthesize isUploading;

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
	NSString *message;
	CurlStatus code;
	
	switch (status)
	{
		case CURLE_OK:
			message = [NSString stringWithFormat:@"Finished uploading %d files to %@", [transfer totalFiles], [transfer hostname]];
			break;
		
		case CURLE_LOGIN_DENIED:
			message = [NSString stringWithFormat:@"Invalid login for '%@@%@'", [transfer username], [transfer hostname]];
			break;
		
		case CURLE_FTP_ACCESS_DENIED:
			message = [NSString stringWithFormat:@"Failed writing to directory '%@'", [transfer directory]];
			break;
			
		case CURLE_COULDNT_CONNECT:
			message = [NSString stringWithFormat:@"Couldn't connect to host '%@' on port %d", [transfer hostname], [transfer port]];
			break;
			
		case CURLE_OPERATION_TIMEOUTED:
			message = [NSString stringWithFormat:@"Operation timed out to host '%@'", [transfer hostname]];
			break;
			
		case CURLE_COULDNT_RESOLVE_HOST:
			message = [NSString stringWithFormat:@"Couldn't resolve host '%@'", [transfer hostname]];
			break;
			
		case CURLE_RECV_ERROR:
			message = [NSString stringWithFormat:@"Failed to receive network data from '%@'", [transfer hostname]];
			break;
			
	   case CURLE_UNSUPPORTED_PROTOCOL:
			message = [NSString stringWithFormat:@"Unsupported protocol '%@'", [transfer hostname]];
			break;
				   
		default:
			message = [NSString stringWithFormat:@"Unhandled Status Code: %d (%s)", status, url];
			break;
	}
	
	[transfer setStatusMessage:message];
	NSLog(message);
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
	NSLog(@"uploadDidBegin: %d files to %@", [aRecord totalFiles], [aRecord hostname]);
	if (delegate && [delegate respondsToSelector:@selector(uploadDidBegin:)])
	{
		[delegate uploadDidBegin:aRecord];
	}
}


- (void)uploadDidProgress:(id <TransferRecord>)aRecord toPercent:(int)aPercent
{
	NSLog(@"uploadDidProgress:%@ toPercent:%d\n", [aRecord currentFile], aPercent);
	
	if (delegate && [delegate respondsToSelector:@selector(uploadDidProgress:toPercent:)])
	{
		[delegate uploadDidProgress:aRecord toPercent:aPercent];
	}
}


- (void)uploadDidFinish:(id <TransferRecord>)aRecord
{
	NSLog(@"uploadDidFinish: %d files to %@", [aRecord totalFiles], [aRecord hostname]);
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
	
	if (![client isUploading] && uploadProgress > 0)
	{
		[client uploadDidBegin:transfer];

		[client setIsUploading:YES];
	}
	
	[transfer setProgress:uploadProgress];
	
	[client uploadDidProgress:transfer toPercent:uploadProgress];
	
	return 0;
}


@end
