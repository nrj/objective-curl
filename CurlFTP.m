//
//  CurlFTP.m
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlFTP.h"


int const DEFAULT_FTP_PORT = 21;

NSString * const FTP_PROTOCOL_PREFIX = @"ftp";

@implementation CurlFTP

/*
 * Initializes the class instance for performing FTP uploads. If you don't use this method then you will have to manually set some or all 
 * of these options before doing any uploads
 */
- (id)init
{		
	if (self = [super init])
	{
		[self setProtocolType:kSecProtocolTypeFTP];

		directoryListCache = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}


/*
 * Cleanup.
 */
- (void)dealloc
{
	[directoryListCache release];
	
	[super dealloc];
}


- (CURL *)newHandle
{
	CURL *handle = [super newHandle];
	
	curl_easy_setopt(handle, CURLOPT_FTP_CREATE_MISSING_DIRS, 1L);
	
	return handle;
}


/*
 * Returns the URL prefix for FTP transfers.
 */
- (NSString * const)protocolPrefix
{
	return FTP_PROTOCOL_PREFIX;
}


/*
 * Returns an array of files that exist in a remote directory. Will use items in the directoryListCache if they exist. Uses 
 * the default FTP port.
 */
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host
{
	return [self listRemoteDirectory:directory 
							  onHost:host
						 forceReload:NO
								port:DEFAULT_FTP_PORT];
}


/*
 * Returns an array of files that exist in a remote directory. The forceReload flag will bypass using the directoryListCache and
 * always return a fresh listing from the specified server.  Uses the default FTP port.
 */
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload
{
	return [self listRemoteDirectory:directory 
							  onHost:host 
						 forceReload:reload 
								port:DEFAULT_FTP_PORT];
}


/*
 * Returns an array of files that exist in a remote directory. The forceReload flag will bypass using the directoryListCache and
 * always return a fresh listing from the specified server and port number.
 */
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload port:(int)port
{	
	RemoteFolder *folder = [[RemoteFolder alloc] init];
	
	[folder setProtocol:[self protocolType]];
	[folder setHostname:host];
	[folder setPort:port];
	[folder setPath:[directory pathForFTP]];
	[folder setForceReload:reload];
	
	[NSThread detachNewThreadSelector:@selector(performListRemoteDirectory:)
							 toTarget:self 
						   withObject:folder];
	
	return folder;	
}


/*
 * Use this method to retry a failed recursive upload.
 */
- (void)retryListRemoteDirectory:(RemoteFolder *)folder;
{
	
}


/*
 * Recursively upload a list of files and directories using the specified host and the users home directory.
 */
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
								 directory:@""
									  port:DEFAULT_FTP_PORT];
}


/*
 * Recursively upload a list of files and directories using the specified host and directory.
 */
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
								 directory:directory
									  port:DEFAULT_FTP_PORT];	
}


/*
 * Recursively upload a list of files and directories using the specified host, directory and port number. The associated Upload object
 * is returned, however not retained.
 */
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory port:(int)port
{		
	Upload *upload = [[Upload alloc] init];
	
	[upload setProtocol:[self protocolType]];
	[upload setHostname:host];
	[upload setPort:port];
	[upload setDirectory:[directory pathForFTP]];
	[upload setLocalFiles:filesAndDirectories];
	[upload setProgress:0];
	
	[NSThread detachNewThreadSelector:@selector(performRecursiveUpload:)
							 toTarget:self 
						   withObject:upload];
	
	return upload;
}


/*
 * Use this method to retry a failed recursive upload.
 */
- (void)retryRecursiveUpload:(Upload *)upload
{
	[NSThread detachNewThreadSelector:@selector(performRecursiveUpload:)
							 toTarget:self 
						   withObject:upload];	
}


/* 
 * Returns a string that can be used for FTP authentication, "username:password", if no username is specified then "anonymous" will 
 * be used. If a username is present but no password is set, then the users keychain is checked.
 */
- (NSString *)credentials
{
	NSString *creds;
	if ([self hasAuthUsername])
	{
		if (![self hasAuthPassword])
		{
			// Try Keychain
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


# pragma mark UploadDelegate methods


/*
 * Called when the upload starts.
 */
- (void)uploadDidBegin:(Upload *)record
{
	
}


/*
 * Called when the upload has finished successfully.
 */
- (void)uploadDidFinish:(Upload *)record
{
	
}


/*
 * Called when the upload progress has changed (1-100%)
 */
- (void)upload:(Upload *)record didProgress:(int)percent
{
	
}


/*
 * Called when the status of the upload changes.
 */
- (void)upload:(Upload *)record statusDidChange:(TransferStatus)status
{
	
}


@end
