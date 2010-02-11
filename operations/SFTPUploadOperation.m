//
//  SFTPUploadOperation.m
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import "SFTPUploadOperation.h"
#import "Upload.h"
#import "NSString+MD5.h"
#import "NSObject+Extensions.h"


NSString * const SFTP_PROTOCOL_PREFIX = @"sftp";

@implementation SFTPUploadOperation


/*
 * Invoked by curl when the known_host key matching is done. Returns a curl_khstat that determines how to proceed. 
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTSSHKEYFUNCTION
 */
static int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, SFTPUploadOperation *operation)
{			
	int result = -1;
	
	Upload *transfer = [operation transfer];
	
	NSString *receivedKey = [NSString formattedMD5:foundKey->key length:foundKey->len];
	
	switch (type)
	{
		case CURLKHMATCH_OK:
			result = CURLKHSTAT_FINE;
			break;
			
		case CURLKHMATCH_MISSING:
			result = [operation acceptUnknownFingerprint:receivedKey forHost:[transfer hostname]];
			break;
			
		case CURLKHMATCH_MISMATCH:
			result = [operation acceptMismatchedFingerprint:receivedKey forHost:[transfer hostname]];
			break;
		
		default:
			result = CURLKHSTAT_REJECT;
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
 * How should we handle the unknown host key fingerprint. If a delegate implementation exists then query
 * the delegate for an answer. Otherwise proceed.
 *
 */
- (int)acceptUnknownFingerprint:(NSString *)fingerprint forHost:(NSString *)hostname
{
	int answer = CURLKHSTAT_DEFER;
	
	if (delegate && [delegate respondsToSelector:@selector(acceptUnknownFingerprint:forHost:)])
	{
		answer = [[delegate invokeOnMainThreadAndWaitUntilDone:YES] acceptUnknownFingerprint:fingerprint forHost:hostname];
	}
	else
	{
		[self showUnknownKeyWarningForHost:hostname];
	}
	
	return answer;
}


/*
 * How should we handle the mismatched host key fingerprint. If a delegate implementation exists then query
 * the delegate for an answer. Otherwise proceed.
 *
 */
- (int)acceptMismatchedFingerprint:(NSString *)fingerprint forHost:(NSString *)hostname
{	
	int answer = CURLKHSTAT_DEFER;
	
	if (delegate && [delegate respondsToSelector:@selector(acceptMismatchedFingerprint:forHost:)])
	{
		answer = [[delegate invokeOnMainThreadAndWaitUntilDone:YES] acceptMismatchedFingerprint:fingerprint forHost:hostname];
	}
	else
	{
		[self showMismatchKeyWarningForHost:hostname];	
	}
	
	return answer;
}


/*
 * Returns a char pointer containing the delete temp file command. Be sure to call free() on the result.
 *
 */
- (char *)removeTempFileCommand:(NSString *)basePath
{
	NSString *path = [basePath stringByAppendingPathComponent:TMP_FILENAME];			
	char *command = malloc(strlen("rm \"%s\"") + [path length] + 1);
	sprintf(command, "rm \"%s\"", [path UTF8String]);
	return command;
}


/*
 * Returns the prefix for the protocol being used. In this case "sftp".
 */
- (NSString *)protocolPrefix
{
	return SFTP_PROTOCOL_PREFIX;
}


/*
 * Log warning for unknown hostKey.
 */
- (void)showUnknownKeyWarningForHost:(NSString *)hostname
{
	NSLog(@"The authenticity of host '%@' can't be established.", hostname);
	NSLog(@"See the SSHDelegate protocol for how to implement 'acceptUnknownFingerprint:forHost:'"); 
}


/*
 * Log warning for mismatched hostKey.
 */
- (void)showMismatchKeyWarningForHost:(NSString *)hostname
{
	NSLog(@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
	NSLog(@"@ WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED! @");
	NSLog(@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
	NSLog(@"Someone could be eavesdropping on you right now (man-in-the-middle attack)!");
	NSLog(@"It is also possible that the RSA host key for '%@' has just been changed.", hostname);
	NSLog(@"See the SSHDelegate protocol for how to implement 'acceptMismatchedFingerprint:forHost:'"); 
}


@end
