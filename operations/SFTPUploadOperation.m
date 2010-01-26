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

// TODO - Add these in setup 
//
//		curl_easy_setopt(handle, CURLOPT_SSH_KEYFUNCTION, hostKeyCallback);
//		curl_easy_setopt(handle, CURLOPT_SSH_KEYDATA, self);
//

- (NSString *)protocolPrefix
{
	return SFTP_PROTOCOL_PREFIX;
}


/*
 * Invoked by curl when the known_host key matching is done. Returns a curl_khstat that determines how to proceed. 
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTSSHKEYFUNCTION
 */
static int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, Upload *transfer)
{			
	int result = -1;
//	NSString *fingerprint = [NSString formattedMD5:foundKey->key length:foundKey->len];
//	switch (type)
//	{
//		case CURLKHMATCH_OK:
//			result = CURLKHSTAT_FINE;
//			break;
//			
//		case CURLKHMATCH_MISSING:
//			result = [client handleUnknownHostKey:fingerprint];
//			break;
//			
//		case CURLKHMATCH_MISMATCH:
//			result = [client handleMismatchedHostKey:fingerprint];
//			break;
//			
//		default:
//			NSLog(@"Unknown curl_khmatch type: %d", type);
//			break;
//	}
//	
	return result;
}


@end
