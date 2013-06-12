//
//  CurlSFTP.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "NSString+PathExtras.h"

#import "CurlSFTP.h"
#import "CurlClientType.h"
#import "CurlUpload.h"
#import "CurlSSHUploadOperation.h"

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


- (NSString *)protocolPrefix
{
	return @"sftp";
}


- (int)defaultPort
{
	return 22;
}


- (int)clientType
{	
	return CURL_CLIENT_SFTP;
}


- (void)upload:(CurlUpload *)record
{
	CurlSSHUploadOperation *op = [[CurlSSHUploadOperation alloc] initWithHandle:[self newHandle] delegate:delegate];
	
	[record setCanUsePublicKeyAuth:YES];
	[record setProgress:0];
	[record setStatus:CURL_TRANSFER_STATUS_QUEUED];
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
- (CurlRemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host
{
	return [self listRemoteDirectory:directory 
							  onHost:host
						 forceReload:NO
								port:[self defaultPort]];
}


/*
 * Returns an array of files that exist in a remote directory. The forceReload flag will bypass using the directoryListCache and
 * always return a fresh listing from the specified server. Uses the default SFTP port.
 */
- (CurlRemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload
{
	return [self listRemoteDirectory:directory 
							  onHost:host
						 forceReload:reload
								port:[self defaultPort]];
}


@end