//
//  CurlSFTP.m
//  objective-curl
//
//  Created by nrj on 12/27/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlSFTP.h"


int const DEFAULT_SFTP_PORT	= 22;

NSString * const DEFAULT_KNOWN_HOSTS = @"~/.ssh/known_hosts";

@implementation CurlSFTP

@synthesize knownHostsFile;

/*
 * Initializes the class instance for performing FTP uploads. If you don't use this method then you will have to manually set some or all 
 * of these options before doing any uploads
 */
- (id)init
{		
	if (self = [super init])
	{
		[self setProtocolType:kSecProtocolTypeSSH];
		
		hostKeyFingerprints = [[NSMutableDictionary alloc] init];
		
		[self setKnownHostsFile:[DEFAULT_KNOWN_HOSTS stringByExpandingTildeInPath]];
	}
	
	return self;
}


/*
 * Cleanup
 */
- (void)dealloc
{
	[knownHostsFile release], knownHostsFile = nil;
	[hostKeyFingerprints release], hostKeyFingerprints = nil;

	[super dealloc];
}


/*
 * Generates a new curl_easy_handle with SFTP-specific options set.
 *
 *      See http://curl.haxx.se/libcurl/c/libcurl-easy.html
 */
- (CURL *)newHandle
{
	CURL *handle = [super newHandle];
	
	curl_easy_setopt(handle, CURLOPT_SSH_KNOWNHOSTS, [knownHostsFile UTF8String]);

	return handle;
}


/*
 * Recursively upload a list of files and directories using the specified host and the users home directory.
 */
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
								 directory:@"~/"
									  port:DEFAULT_SFTP_PORT];
}


/*
 * Recursively upload a list of files and directories using the specified host and directory.
 */
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
								 directory:directory
									  port:DEFAULT_SFTP_PORT];	
}


/*
 * Recursively upload a list of files and directories using the specified host and directory.
 */
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory port:(int)port
{
	Upload *upload = [[[Upload alloc] init] autorelease];
	
	[upload setProtocol:[self protocolType]];
	[upload setHostname:host];
	[upload setPort:port];
	[upload setDirectory:[directory pathForFTP]];
	[upload setLocalFiles:filesAndDirectories];
	[upload setProgress:0];
	
	SFTPUploadOperation *op = [[SFTPUploadOperation alloc] initWithHandle:[self newHandle] 
																 delegate:[self delegate]];
	
	[op setTransfer:upload];
	
	[operationQueue addOperation:op];
	
	[op release];
	
	[upload setStatus:TRANSFER_STATUS_QUEUED];
	
	return upload;
}


/*
 * Search the acceptedHostKeys dictionary for the RSA fingerprint and return accordingly. If it is not found the Inform the delegate 
 * that the host we're trying to connect to has an unknown RSA fingerprint.
 */
- (int)handleUnknownHostKey:(NSString *)rsaFingerprint
{
	int result = CURLKHSTAT_DEFER;

	if (delegate && [delegate respondsToSelector:@selector(curl:receivedUnknownHostKeyFingerprint:)])
	{
		[[delegate invokeOnMainThreadAndWaitUntilDone:YES] curl:self receivedUnknownHostKeyFingerprint:rsaFingerprint];
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

	if (delegate && [delegate respondsToSelector:@selector(curl:receivedUnknownHostKeyFingerprint:)])
	{
		[delegate curl:self receivedUnknownHostKeyFingerprint:rsaFingerprint];
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
 * Returns an array of files that exist in a remote directory. Will use items in the directoryListCache if they exist. Uses 
 * the default SFTP port.
 */
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host
{
	return [self listRemoteDirectory:directory 
							  onHost:host
						 forceReload:NO
								port:DEFAULT_SFTP_PORT];
}


/*
 * Returns an array of files that exist in a remote directory. The forceReload flag will bypass using the directoryListCache and
 * always return a fresh listing from the specified server. Uses the default SFTP port.
 */
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload
{
	return [self listRemoteDirectory:directory 
							  onHost:host
						 forceReload:reload
								port:DEFAULT_SFTP_PORT];
}


/* 
 * Overridden since there is no anonymous login for SFTP. Instead try public_key authentication if we don't have a username/password.
 */
- (NSString *)credentials
{
	NSString *creds;
	if ([self hasAuthUsername])
	{
		if (![self hasAuthPassword])
		{
			// TODO - Try Keychain and set password here
		}
		
		creds = [NSString stringWithFormat:@"%@:%@", authUsername, authPassword];
	}
	else
	{
		// Try anonymous login
		creds = [NSString stringWithFormat:@"anonymous:"];
	}
	
	return creds;
}


@end