//
//  CurlOperation.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
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
	handle = NULL;
	
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
			message = [NSString stringWithFormat:@"No files found to upload."];
			break;
			
		case CURLE_UNSUPPORTED_PROTOCOL:
			message = [NSString stringWithFormat:@"Unsupported protocol %@", [object protocolPrefix]];
			break;

		case CURLE_URL_MALFORMAT:
			message = [NSString stringWithFormat:@"Malformed URL %@", [object uri]];			
			break;
		
		case CURLE_COULDNT_RESOLVE_PROXY:
			message = [NSString stringWithFormat:@"Couldn't resolve proxy %@", [object hostname]];
			break;
			
		case CURLE_COULDNT_RESOLVE_HOST:
			message = [NSString stringWithFormat:@"Couldn't resolve host %@", [object hostname]];
			break;
			
		case CURLE_COULDNT_CONNECT:
			message = [NSString stringWithFormat:@"Couldn't connect to host %@ on port %d", [object hostname], [object port]];
			break;
			
		case CURLE_FTP_WEIRD_SERVER_REPLY:
			message = [NSString stringWithFormat:@"Invalid response from FTP server at %@", [object hostname]];
			break;
			
		case CURLE_REMOTE_ACCESS_DENIED:
			message = [NSString stringWithFormat:@"Failed writing to directory %@", [object path]];
			break;

		case CURLE_REMOTE_FILE_NOT_FOUND:
			message = [NSString stringWithFormat:@"Remote directory not found %@:%@", [object hostname], [object path]];
			break;			
			
		case CURLE_PARTIAL_FILE:
			message = [NSString stringWithFormat:@"Incorrect number of bytes reported by server: %@", [object uri]];
			break;
			
		case CURLE_UPLOAD_FAILED:
			message = [NSString stringWithFormat:@"Failed to start upload: %@", [object uri]];
			break;
			
		case CURLE_READ_ERROR:
			message = [NSString stringWithFormat:@"Error reading local file."];
			break;

		case CURLE_OUT_OF_MEMORY:
			message = [NSString stringWithFormat:@"cURL ran out of memory..."];
			break;
			
		case CURLE_OPERATION_TIMEDOUT:
			message = [NSString stringWithFormat:@"Operation timed out to host %@", [object hostname]];
			break;
			
		case CURLE_FILE_COULDNT_READ_FILE:
			message = [NSString stringWithFormat:@"Couldn't read local file, invalid permissions?"];
			break;
		
		case CURLE_BAD_FUNCTION_ARGUMENT:
			message = [NSString stringWithFormat:@"Internal error. A function was called with a bad parameter."];
			break;
		
		case CURLE_TOO_MANY_REDIRECTS:
			message = [NSString stringWithFormat:@"Too many redirects. %@", [object uri]];
			break;
			
		case CURLE_PEER_FAILED_VERIFICATION:
			message = [NSString stringWithFormat:@"Host key verification failed for %@", [object hostname]];
			break;
			
		case CURLE_GOT_NOTHING:
			message = [NSString stringWithFormat:@"No response returned from the server at %@", [object hostname]];
			break;
			
		case CURLE_SEND_ERROR:
			message = [NSString stringWithFormat:@"Failed to send network data to %@", [object hostname]];
			break;
			
		case CURLE_RECV_ERROR:
			message = [NSString stringWithFormat:@"Failed to receive network data from %@", [object hostname]];
			break;	
		
		case CURLE_BAD_CONTENT_ENCODING:
			message = [NSString stringWithFormat:@"Unrecognized transfer encoding sent from %@", [object hostname]];
			break;
		
		case CURLE_LOGIN_DENIED:
			message = [NSString stringWithFormat:@"Invalid login for %@@%@", [object username], [object hostname]];
			break;
		
		case CURLE_REMOTE_DISK_FULL:
			message = [NSString stringWithFormat:@"Remote disk is full %@", [object uri]];
			break;
			
		case CURLE_FAILED_INIT:
			message = [NSString stringWithFormat:@"Failed to initialize %@ on %@:%d", [object protocolPrefix], [object hostname], [object port]];
			break;
					
		case CURLE_QUOTE_ERROR:
			message = [NSString stringWithFormat:@"%@ quote command invalid", [object protocolPrefix]];
			break;
			
		default:
			message = [NSString stringWithFormat:@"Unhandled Status Code: %d", status];
			break;
	}
	
	return message;
}


@end