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

@synthesize transfer;
@synthesize isUploading;

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
		[self setAuthUsername:@""];
		[self setAuthPassword:@""];

		handle = curl_easy_init();
		
		if (!handle)
		{
			@throw [NSException exceptionWithName:@"Initialization Error" 
										   reason:@"Unable to initialize libcurl." 
										 userInfo:nil];
		}
		
		curl_easy_setopt(handle, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_WHATEVER);
		curl_easy_setopt(handle, CURLOPT_PROGRESSFUNCTION, handleCurlProgress);
		curl_easy_setopt(handle, CURLOPT_PROGRESSDATA, self);
	}
	
	return self;
}


/*
 * Cleanup. 
 */
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


/*
 * Getter for the curl_easy_handle.
 *
 *      See http://curl.haxx.se/libcurl/c/libcurl-easy.html
 */
- (CURL *)handle
{
	return handle;
}


/*
 * Turn on curls internal verbose logging; output goes to stderr.
 */
- (void)setVerbose:(BOOL)value
{
	if (!handle) return;
	curl_easy_setopt(handle, CURLOPT_VERBOSE, value);
	verbose = value;
}


/*
 * Getter for the verbose flag.
 */
- (BOOL)verbose
{
	return verbose;
}


/*
 * Turn on curls internal progress meter. This needs to be turned on to receive progress callbacks.
 */
- (void)setShowProgress:(BOOL)value
{
	if (!handle) return;
	curl_easy_setopt(handle, CURLOPT_NOPROGRESS, !value);
	showProgress = value;
}


/*
 * Getter for the showProgress flag.
 */
- (BOOL)showProgress
{
	return showProgress;
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
 * Used to handle upload progress if the showProgress flag is set. Invoked by libcurl on progress updates to calculates the 
 * new upload progress and sets it on the transfer.
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTPROGRESSFUNCTION 
 */
static int handleCurlProgress(CurlObject *client, double dltotal, double dlnow, double ultotal, double ulnow)
{	
	id <TransferRecord>transfer = [client transfer];
	
	long totalProgressUnits = 100 * ([transfer totalFiles]);
	long individualProgress = ([transfer totalFilesUploaded] * 100) + (ulnow * 100 / ultotal);
	int actualProgress = (individualProgress * 100) / totalProgressUnits;
	
	if ([transfer hasBeenCancelled])
	{		
		return -1;
	}
	else if (actualProgress >= 0 && actualProgress > [transfer progress])
	{
		[transfer setProgress:actualProgress];

		[transfer setStatusMessage:[NSString stringWithFormat:@"Uploading", actualProgress, [transfer hostname]]];
		
		[client performDelegateSelector:@selector(curl:transferDidProgress:)];
	}
	
	return 0;
}


/*
 * Used to handle a curl response code and sets either the transfer status to either TRANSFER_STATUS_COMPLETE or TRANSFER_STATUS_FAILED
 * along with a detailed statusMessage of what happened.
 */
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
		
		case CURLE_ABORTED_BY_CALLBACK:
			status = TRANSFER_STATUS_CANCELLED;
			message = [NSString stringWithFormat:@"Cancelled"];
			break;
		
		case CURLE_FTP_ACCESS_DENIED:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Failed writing to directory %@", [transfer directory]];
			break;
			
		case CURLE_PEER_FAILED_VERIFICATION:
			status = TRANSFER_STATUS_FAILED;
			message = [NSString stringWithFormat:@"Unknown host key for %@", [transfer hostname]];
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


/*
 * Quick easy way to call a selector on the delegate. This will probably change into something that can handle arguments.
 */
- (void)performDelegateSelector:(SEL)aSelector
{		
	if (delegate && [delegate respondsToSelector:aSelector])
	{
		[delegate performSelector:aSelector withObject:self withObject:transfer];
	}
}


@end