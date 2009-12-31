//
//  CurlSFTP.m
//  objective-curl
//
//  Created by nrj on 12/27/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlSFTP.h"


int const DEFAULT_SFTP_PORT	= 22;

NSString * const SFTP_PROTOCOL_PREFIX = @"sftp";

NSString * const DEFAULT_KNOWN_HOSTS = @"~/.ssh/known_hosts";

@implementation CurlSFTP

/*
 * Initializes the class instance for performing FTP uploads. If you don't use this method then you will have to manually set some or all 
 * of these options before doing any uploads
 */
- (id)initForUpload
{		
	if (self = [super init])
	{
		[self setProtocolType:kSecProtocolTypeSSH];

		[self setKnownHostsFile:[DEFAULT_KNOWN_HOSTS stringByExpandingTildeInPath]];
		
		hostKeyFingerprints = [[NSMutableDictionary alloc] init];

		curl_easy_setopt(handle, CURLOPT_UPLOAD, 1L);
		curl_easy_setopt(handle, CURLOPT_FTP_CREATE_MISSING_DIRS, 1L);
		curl_easy_setopt(handle, CURLOPT_SSH_KEYFUNCTION, hostKeyCallback);
		curl_easy_setopt(handle, CURLOPT_SSH_KEYDATA, self);
	}
	
	return self;
}


/*
 * Cleanup
 */
- (void)dealloc
{
	[knownHostsFile release];
	[hostKeyFingerprints release];
	[super dealloc];
}


/*
 * Returns the URL prefix for SFTP transfers.
 */
- (NSString * const)protocolPrefix
{
	return SFTP_PROTOCOL_PREFIX;
}


/*
 * Invoked by curl when the known_host key matching is done. Returns a curl_khstat that determines how to proceed. 
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTSSHKEYFUNCTION
 */
static int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, CurlSFTP *client)
{			
	int result = -1;
	NSString *fingerprint = [NSString formattedMD5:foundKey->key length:foundKey->len];
	switch (type)
	{
		case CURLKHMATCH_OK:
			result = CURLKHSTAT_FINE;
			break;
			
		case CURLKHMATCH_MISSING:
			result = [client handleUnknownHostKey:fingerprint];
			break;

		case CURLKHMATCH_MISMATCH:
			result = [client handleMismatchedHostKey:fingerprint];
			break;
			
		default:
			NSLog(@"Unknown curl_khmatch type: %d", type);
			break;
	}
	
	return result;
}


/*
 * Search the acceptedHostKeys dictionary for the RSA fingerprint and return accordingly. If it is not found the Inform the delegate 
 * that the host we're trying to connect to has an unknown RSA fingerprint.
 */
- (int)handleUnknownHostKey:(NSString *)rsaFingerprint
{
	int result = CURLKHSTAT_DEFER;

	if (delegate && [delegate respondsToSelector:@selector(curl:transfer:receivedUnknownHostKey:)])
	{
		[delegate curl:self transfer:transfer receivedUnknownHostKey:rsaFingerprint];
	}
	
	for (id key in hostKeyFingerprints)
	{
		if ([rsaFingerprint isEqual:key])
		{
			result = [[hostKeyFingerprints valueForKey:key] intValue];
			break;
		}
	}
	
	return result;
}


/*
 * Search the acceptedHostKeys dictionary for the RSA fingerprint and return accordingly. If it is not found the Inform the delegate 
 * that the host we're trying to connect to has an mismatched RSA fingerprint.
 */		
- (int)handleMismatchedHostKey:(NSString *)rsaFingerprint
{
	int result = CURLKHSTAT_DEFER;

	if (delegate && [delegate respondsToSelector:@selector(curl:transfer:receivedMismatchedHostKey:)])
	{
		[delegate curl:self transfer:transfer receivedMismatchedHostKey:rsaFingerprint];
	}
	
	for (id key in hostKeyFingerprints)
	{
		if ([rsaFingerprint isEqual:key])
		{
			result = [[hostKeyFingerprints valueForKey:key] intValue];
			break;
		}
	}
	
	return result;
}
				

- (void)acceptHostKeyFingerprint:(NSString *)fingerprint permanently:(BOOL)permanent
{
	int status = (permanent ? CURLKHSTAT_FINE_ADD_TO_FILE : CURLKHSTAT_FINE);
	
	[hostKeyFingerprints setObject:[NSNumber numberWithInt:status] 
							forKey:fingerprint];	
}


- (void)rejectHostKeyFingerprint:(NSString *)fingerprint
{
	[hostKeyFingerprints setObject:[NSNumber numberWithInt:CURLKHSTAT_REJECT] 
							forKey:fingerprint];
}

/*
 * Set the path to use for the OpenSSH known_hosts file. Default is ~/.ssh/known_hosts
 */
- (void)setKnownHostsFile:(NSString *)filePath
{		
	if (knownHostsFile != filePath)
	{
		[knownHostsFile release];
		knownHostsFile = [filePath copy];		
		curl_easy_setopt(handle, CURLOPT_SSH_KNOWNHOSTS, [knownHostsFile UTF8String]);
	}
}


/*
 * Returns the path set for the OpenSSH known_hosts file.
 */
- (NSString *)knownHostsFile
{
	return knownHostsFile;
}


/*
 * Recursively upload a list of files and directories using the specified host and the users home directory.
 */
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
								 directory:@""
									  port:DEFAULT_SFTP_PORT];
}


/*
 * Recursively upload a list of files and directories using the specified host and directory.
 */
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
								 directory:directory
									  port:DEFAULT_SFTP_PORT];	
}


@end
