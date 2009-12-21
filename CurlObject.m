//
//  CurlObject.m
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlObject.h"
#import "TransferStatus.h"


/*
 * Private Methods
 */
@implementation CurlObject (Private)


static int handleClientProgress(void *clientp, double dltotal, double dlnow, double ultotal, double ulnow)
{	
	CurlObject *client = (CurlObject *)clientp;
	id <TransferRecord>transfer = [client transfer];
	
	long totalProgressUnits = 100 * ([transfer totalFiles] + 1);
	long individualProgress = ([transfer totalFilesUploaded] * 100) + (ulnow * 100 / ultotal);
	int actualProgress = (individualProgress * 100) / totalProgressUnits;
	
	if (actualProgress >= 0)
	{
		[transfer setProgress:actualProgress];
		[transfer setStatusMessage:[NSString stringWithFormat:@"Uploading (%d%%) to %@", actualProgress, [transfer hostname]]];
		[client performDelegateSelector:@selector(curl:transferDidProgress:)];
	}
	
	return 0;
}


@end


/*
 * Main Implementation
 */
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
		
		//[self setDefaultTimeout:15];
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


- (BOOL)hasAuthUsername
{
	return (authUsername != NULL && ![authUsername isEqualToString:@""]);
}


- (BOOL)hasAuthPassword
{
	return (authPassword != NULL && ![authPassword isEqualToString:@""]);
}


- (void)handleCurlResult:(CURLcode)result
{
	// char *url;
	// curl_easy_getinfo(handle, CURLINFO_EFFECTIVE_URL, &url); 
	NSString *message;
	TransferStatus status;
	
	switch (result)
	{
		case CURLE_OK:
			status = TRANSFER_STATUS_COMPLETE;
			message = [NSString stringWithFormat:@"Finished uploading %d files to %@", [transfer totalFiles], [transfer hostname]];
			break;
		
		case CURLE_LOGIN_DENIED:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Invalid login for '%@@%@'", 
					   ([self hasAuthUsername] ? [self authUsername] : @"anonymous"), [transfer hostname]];
			break;
		
		case CURLE_FTP_ACCESS_DENIED:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Failed writing to directory '%@'", [transfer directory]];
			break;
			
		case CURLE_COULDNT_CONNECT:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Couldn't connect to host '%@' on port %d", [transfer hostname], [transfer port]];
			break;
			
		case CURLE_OPERATION_TIMEOUTED:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Operation timed out to host '%@'", [transfer hostname]];
			break;
			
		case CURLE_COULDNT_RESOLVE_HOST:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Couldn't resolve host '%@'", [transfer hostname]];
			break;
			
		case CURLE_RECV_ERROR:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Failed to receive network data from '%@'", [transfer hostname]];
			break;
			
	   case CURLE_UNSUPPORTED_PROTOCOL:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Unsupported protocol '%@'", [transfer hostname]];
			break;
				   
		default:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Unhandled Status Code: %d", status];
			break;
	}

	[transfer setStatus:status];
	[transfer setStatusMessage:message];
	
	[self performDelegateSelector:@selector(curl:transferStatusDidChange:)];
	
	if (result == CURLE_LOGIN_DENIED)
	{
		[self performDelegateSelector:@selector(curl:transferFailedAuthentication:)];
	}
	else if (result == CURLE_OK)
	{
		[self performDelegateSelector:@selector(curl:transferDidFinish:)];
	}
	
//	NSLog(message);
}


- (void)performDelegateSelector:(SEL)aSelector
{		
	if (delegate && [delegate respondsToSelector:aSelector])
	{
		[delegate performSelector:aSelector withObject:self withObject:transfer];
	}
}


@end