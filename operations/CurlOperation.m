//
//  CurlOperation.m
//  objective-curl
//
//  Base class for all curl related operations.
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import "CurlOperation.h"
#import "RemoteObject.h"


@implementation CurlOperation

@synthesize delegate;


/*
 * Init with the curl handle to use, and a UploadDelegate.
 */
- (id)initWithHandle:(CURL *)aHandle delegate:(id)aDelegate
{
	if (self = [super init])
	{
		handle = aHandle;
		
		[self setDelegate:aDelegate];
	}

	return self;
}


/*
 * Cleanup. Closes any open connections.
 */
- (void)dealloc
{
	curl_easy_cleanup(handle);

	curl_global_cleanup();
	
	[super dealloc];
}


/*
 * Return a failure status message for CURLcode.
 */
- (NSString *)getFailureDetailsForStatus:(CURLcode)status withObject:(RemoteObject *)object
{
	NSString *message;
	
	switch (status)
	{	
		case -1:
			message = [NSString stringWithFormat:@"Nothing to do."];
			break;
			
		case CURLE_LOGIN_DENIED:
			message = [NSString stringWithFormat:@"Invalid login for %@@%@", [object username], [object hostname]];
			break;
			
		case CURLE_REMOTE_ACCESS_DENIED:
			message = [NSString stringWithFormat:@"Failed writing to directory %@", [object path]];
			break;
			
		case CURLE_PEER_FAILED_VERIFICATION:
			message = [NSString stringWithFormat:@"Host key verification failed for %@", [object hostname]];
			break;
			
		case CURLE_FAILED_INIT:
			message = [NSString stringWithFormat:@"Failed to initialize %@ on %@:%d", [object protocolString], [object hostname], [object port]];
			break;
			
		case CURLE_COULDNT_CONNECT:
			message = [NSString stringWithFormat:@"Couldn't connect to host %@ on port %d", [object hostname], [object port]];
			break;
			
		case CURLE_OPERATION_TIMEOUTED:
			message = [NSString stringWithFormat:@"Operation timed out to host %@", [object hostname]];
			break;
			
		case CURLE_COULDNT_RESOLVE_HOST:
			message = [NSString stringWithFormat:@"Couldn't resolve host %@", [object hostname]];
			break;
			
		case CURLE_RECV_ERROR:
			message = [NSString stringWithFormat:@"Failed to receive network data from %@", [object hostname]];
			break;
			
		case CURLE_UNSUPPORTED_PROTOCOL:
			message = [NSString stringWithFormat:@"Unsupported protocol %@", [object protocolString]];
			break;
		
		default:
			message = [NSString stringWithFormat:@"Unhandled Status Code: %d", status];
			break;
	}
	
	return message;
}


@end