//
//  SSHUploadOperation.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "CurlSSHUploadOperation.h"
#import "CurlUpload.h"
#import "CurlFileTransfer.h"
#import "NSString+MD5.h"
#import "NSString+PathExtras.h"
#import "NSObject+DDExtensions.h"


@implementation CurlSSHUploadOperation


/*
 * Invoked by curl when the known_host key matching is done. Returns a curl_khstat that determines how to proceed. 
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTSSHKEYFUNCTION
 */
static int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, CurlSSHUploadOperation *operation)
{			
	int result = -1;
	
	CurlUpload *transfer = [operation upload];
	
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


- (void)setProtocolSpecificOptions
{
	[super setProtocolSpecificOptions];
	
	curl_easy_setopt(handle, CURLOPT_SSH_KEYFUNCTION, hostKeyCallback);
	curl_easy_setopt(handle, CURLOPT_SSH_KEYDATA, self);
	
	if ([upload usePublicKeyAuth])
	{
		curl_easy_setopt(handle, CURLOPT_SSH_PRIVATE_KEYFILE, [[upload privateKeyFile] UTF8String]);
		curl_easy_setopt(handle, CURLOPT_SSH_PUBLIC_KEYFILE, [[upload publicKeyFile] UTF8String]);
		curl_easy_setopt(handle, CURLOPT_KEYPASSWD, [[upload password] UTF8String]);
	}
}


- (void)setFileSpecificOptions:(CurlFileTransfer *)file
{
	if ([file isEmptyDirectory])
	{
		const char *removeTempFile = [[NSString stringWithFormat:@"RM \"%@\"", [[file remotePath] stringByRemovingTildePrefix]] UTF8String];
		
		[file appendPostQuote:removeTempFile];
	}
	
	curl_easy_setopt(handle, CURLOPT_POSTQUOTE, [file postQuote]);
}


- (NSString *)urlForTransfer:(CurlFileTransfer *)file
{
	NSString *filePath = [[file remotePath] stringByRemovingTildePrefix];
		
	NSString *path = [[NSString stringWithFormat:@"%@:%d", [upload hostname], [upload port]] stringByAppendingPathComponent:[filePath stringByAddingTildePrefix]];
		
	NSString *url = [NSString stringWithFormat:@"%@://%@", [upload protocolPrefix], path];
		
	return url;
}


/*
 * How should we handle the unknown host key fingerprint. If a delegate implementation exists then query
 * the delegate for an answer. Otherwise proceed.
 *
 */
- (int)acceptUnknownHostFingerprint:(NSString *)fingerprint forUpload:(CurlUpload *)record
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
- (int)acceptMismatchedHostFingerprint:(NSString *)fingerprint forUpload:(CurlUpload *)record
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
