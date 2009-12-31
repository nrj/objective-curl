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

@synthesize verbose;
@synthesize showProgress;
@synthesize isUploading;

@synthesize authUsername;
@synthesize authPassword;

@synthesize transfer;


- (id)init
{
	if (self = [super init])
	{
		[self setAuthUsername:@""];
		[self setAuthPassword:@""];

		handle = curl_easy_init();
		
		if (!handle)
		{
			@throw [NSException exceptionWithName:@"Initialization Error" 
										   reason:@"Unable to initialize libcurl." 
										 userInfo:nil];
		}
	}
	
	return self;
}


- (void)dealloc
{
	[authUsername release];
	[authPassword release];
	
	if (handle)
	{
		curl_easy_cleanup(handle);
	}
	
	curl_global_cleanup();
	
	[super dealloc];
}


- (CURL *)handle
{
	return handle;
}


+ (NSString *)libcurlVersion
{		
	return [NSString stringWithCString:curl_version()];
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
	curl_easy_setopt(handle, CURLOPT_NOPROGRESS, !value);
	showProgress = value;
}


- (BOOL)showProgress
{
	return showProgress;
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
	NSString *message;
	TransferStatus status;
	
	switch (result)
	{
		case CURLE_OK:
			status = TRANSFER_STATUS_COMPLETE;
			message = [NSString stringWithFormat:@"Finished", [transfer totalFiles], [transfer hostname]];
			break;
		
		case CURLE_LOGIN_DENIED:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Invalid login for %@@%@", 
					   ([self hasAuthUsername] ? [self authUsername] : @"anonymous"), [transfer hostname]];
			break;
		
		case CURLE_FTP_ACCESS_DENIED:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Failed writing to directory %@", [transfer directory]];
			break;
			
		case CURLE_FAILED_INIT:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Failed to initialize %@ on %@:%d", [transfer protocolString], [transfer hostname], [transfer port]];
			break;
			
		case CURLE_COULDNT_CONNECT:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Couldn't connect to host %@ on port %d", [transfer hostname], [transfer port]];
			break;
			
		case CURLE_OPERATION_TIMEOUTED:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Operation timed out to host %@", [transfer hostname]];
			break;
			
		case CURLE_COULDNT_RESOLVE_HOST:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Couldn't resolve host %@", [transfer hostname]];
			break;
			
		case CURLE_RECV_ERROR:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Failed to receive network data from %@", [transfer hostname]];
			break;
			
	   case CURLE_UNSUPPORTED_PROTOCOL:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Unsupported protocol %@", [transfer protocolString]];
			break;
				   
		default:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Unhandled Status Code: %d", result];
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
}


- (void)performDelegateSelector:(SEL)aSelector
{		
	if (delegate && [delegate respondsToSelector:aSelector])
	{
		[delegate performSelector:aSelector withObject:self withObject:transfer];
	}
}


@end