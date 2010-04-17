//
//  CurlSFTP.m
//  objective-curl
//
//  Created by nrj on 12/27/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlSFTP.h"
#import "Upload.h"
#import "SFTPUploadOperation.h"
#import "NSString+PathExtras.h"


int const DEFAULT_SFTP_PORT	= 22;

NSString * const SFTP_PROTOCOL_PREFIX = @"sftp";

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
		[self setProtocol:kSecProtocolTypeSSH];
		
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


- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:hostname
								  username:username
								  password:@""
								 directory:@"~/"
									  port:DEFAULT_SFTP_PORT];
}


- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:hostname
								  username:username
								  password:password
								 directory:@""
									  port:DEFAULT_SFTP_PORT];	
}


- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:hostname
								  username:username
								  password:password
								 directory:directory
									  port:DEFAULT_SFTP_PORT];	
}


- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory port:(int)port
{
	Upload *upload = [[[Upload alloc] init] autorelease];
	
	[upload setProtocol:[self protocol]];
	[upload setProtocolPrefix:SFTP_PROTOCOL_PREFIX];
	[upload setLocalFiles:filesAndDirectories];
	[upload setHostname:hostname];
	[upload setUsername:username];
	[upload setPassword:password];
	[upload setPath:[directory pathForFTP]];
	[upload setPort:port];
			
	[self upload:upload];
	
	return upload;
}


- (void)upload:(Upload *)record
{
	SFTPUploadOperation *op = [[SFTPUploadOperation alloc] initWithHandle:[self newHandle] delegate:delegate];
	
	[record setProgress:0];
	[record setStatus:TRANSFER_STATUS_QUEUED];
	[record setConnected:NO];
	[record setCancelled:NO];	
	
	[op setUpload:record];
	[operationQueue addOperation:op];
	[op release];
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


@end