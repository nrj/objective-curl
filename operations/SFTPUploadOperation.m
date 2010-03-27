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
			result = [operation acceptUnknownHostFingerprint:receivedKey forUpload:transfer];
			break;
			
		case CURLKHMATCH_MISMATCH:
			result = [operation acceptMismatchedHostFingerprint:receivedKey forUpload:transfer];
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
- (int)acceptUnknownHostFingerprint:(NSString *)fingerprint forUpload:(Upload *)record
{
	int answer = CURLKHSTAT_DEFER;
	
	if (delegate && [delegate respondsToSelector:@selector(acceptUnknownHostFingerprint:forUpload:)])
	{
		answer = [[delegate invokeOnMainThreadAndWaitUntilDone:YES] 
					acceptUnknownHostFingerprint:fingerprint forUpload:record];
	}
	else
	{
		[self showUnknownKeyWarningForHost:[record hostname]];
	}
	
	return answer;
}


/*
 * How should we handle the mismatched host key fingerprint. If a delegate implementation exists then query
 * the delegate for an answer. Otherwise proceed.
 *
 */
- (int)acceptMismatchedHostFingerprint:(NSString *)fingerprint forUpload:(Upload *)record
{	
	int answer = CURLKHSTAT_DEFER;
	
	if (delegate && [delegate respondsToSelector:@selector(acceptMismatchedHostFingerprint:forUpload:)])
	{
		answer = [[delegate invokeOnMainThreadAndWaitUntilDone:YES] 
					acceptMismatchedHostFingerprint:fingerprint forUpload:record];
	}
	else
	{
		[self showMismatchKeyWarningForHost:[record hostname]];	
	}
	
	return answer;
}


/*
 * Returns a char pointer containing the delete temp file command. Be sure to call free() on the result.
 *
 */
- (char *)removeTempFileCommand:(NSString *)tmpFilePath
{	
	char *command = malloc(strlen("RM \"\"") + [tmpFilePath length] + 1);
	sprintf(command, "RM \"%s\"", [tmpFilePath UTF8String]);
	return command;
}


/*
 * Log warning for unknown hostKey.
 */
- (void)showUnknownKeyWarningForHost:(NSString *)hostname
{
	NSLog(@"The authenticity of host '%@' can't be established.", hostname);
	NSLog(@"See the UploadDelegate protocol for how to implement 'acceptUnknownHostFingerprint:forUpload:'"); 
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
	NSLog(@"See the SSHDelegate protocol for how to implement 'acceptMismatchedHostFingerprint:forUpload:'"); 
}


@end
