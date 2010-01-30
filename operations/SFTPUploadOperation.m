//
//  SFTPUploadOperation.m
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import "SFTPUploadOperation.h"


NSString * const SFTP_PROTOCOL_PREFIX = @"sftp";

@implementation SFTPUploadOperation


/*
 * Invoked by curl when the known_host key matching is done. Returns a curl_khstat that determines how to proceed. 
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTSSHKEYFUNCTION
 */
static int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, Upload *transfer)
{			
	int result = -1;
	
	//NSString *fingerprint = [NSString formattedMD5:foundKey->key length:foundKey->len];
	
	switch (type)
	{
		case CURLKHMATCH_OK:
			result = CURLKHSTAT_FINE;
			break;
			
		case CURLKHMATCH_MISSING:
			result = CURLKHSTAT_FINE;
			break;
			
		case CURLKHMATCH_MISMATCH:
			result = CURLKHSTAT_FINE;
			break;
		
		default:
			NSLog(@"Unknown curl_khmatch type: %d", type);
			break;
	}
	
	return result;
}


/*
 * Thread entry point for recursive SFTP uploads.
 */
- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	curl_easy_setopt(handle, CURLOPT_SSH_KEYFUNCTION, hostKeyCallback);
	curl_easy_setopt(handle, CURLOPT_SSH_KEYDATA, self);

	[super main];
	
	[pool release];
}


/*
 * Returns the prefix for the protocol being used. In this case "sftp".
 */
- (NSString *)protocolPrefix
{
	return SFTP_PROTOCOL_PREFIX;
}


@end
