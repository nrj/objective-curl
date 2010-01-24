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

@synthesize isUploading;
@synthesize isDownloading;


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
 * Initialize the curl handle and set non-protocol-specific options. Throws an error if we can't initialize curl.
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

	// curl_easy_setopt(handle, CURLOPT_PROGRESSFUNCTION, handleCurlProgress);
	// curl_easy_setopt(handle, CURLOPT_PROGRESSDATA, self);
	
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


/*
 * Abstract. Override this in your subclasses to return the protocols URL prefix.
 *
 *      Example: ftp, sftp
 */
- (NSString * const)protocolPrefix
{
	@throw [NSException exceptionWithName:@"No Implementation" 
								   reason:@"Method must be implemented in a subclass." 
								 userInfo:nil];	
}


/*
 * Used to handle a curl transfer response code and sets either the transfer status to either TRANSFER_STATUS_COMPLETE or TRANSFER_STATUS_FAILED
 * along with a detailed statusMessage of what happened.
 */
- (void)handleCurlResult:(CURLcode)result forObject:(RemoteObject *)task 
{
	NSString *message;
	TransferStatus status;
	
	switch (result)
	{
		case CURLE_OK:
			status = TRANSFER_STATUS_COMPLETE;
			message = [NSString stringWithFormat:@"Finished"];
			break;
		
		case CURLE_ABORTED_BY_CALLBACK:
			status = TRANSFER_STATUS_CANCELLED;
			message = [NSString stringWithFormat:@"Cancelled"];
			break;
		
		case CURLE_REMOTE_ACCESS_DENIED:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Failed writing to directory %@", [task directory]];
			break;
			
		case CURLE_PEER_FAILED_VERIFICATION:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Unknown host key for %@", [task hostname]];
			break;
			
		case CURLE_FAILED_INIT:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Failed to initialize %@ on %@:%d", [task protocolString], [task hostname], [task port]];
			break;
			
		case CURLE_COULDNT_CONNECT:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Couldn't connect to host %@ on port %d", [task hostname], [task port]];
			break;
			
		case CURLE_OPERATION_TIMEOUTED:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Operation timed out to host %@", [task hostname]];
			break;
			
		case CURLE_COULDNT_RESOLVE_HOST:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Couldn't resolve host %@", [task hostname]];
			break;
			
		case CURLE_RECV_ERROR:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Failed to receive network data from %@", [task hostname]];
			break;
			
	   case CURLE_UNSUPPORTED_PROTOCOL:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Unsupported protocol %@", [task protocolString]];
			break;
				   
		default:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Unhandled Status Code: %d", result];
			break;
	}

	[task setStatus:status];
	[task setStatusMessage:message];
}


@end