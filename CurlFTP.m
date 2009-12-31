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
- (id)initForUpload
{		
	if (self = [super init])
	{
		[self setProtocolType:kSecProtocolTypeFTP];

		curl_easy_setopt(handle, CURLOPT_UPLOAD, 1L);
		curl_easy_setopt(handle, CURLOPT_FTP_CREATE_MISSING_DIRS, 1L);
	}
	
	return self;
}


/*
 * Cleanup.
 */
- (void)dealloc
{
	[super dealloc];
}


/*
 * Returns the URL prefix for SFTP transfers.
 */
- (NSString * const)protocolPrefix
{
	return FTP_PROTOCOL_PREFIX;
}


/*
 * Recursively upload a list of files and directories using the specified host and the users home directory.
 */
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
								 directory:@"~/"
									  port:DEFAULT_FTP_PORT];
}


/*
 * Recursively upload a list of files and directories using the specified host and directory.
 */
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
								 directory:directory
									  port:DEFAULT_FTP_PORT];	
}


/*
 * Recursively upload a list of files and directories using the specified host, directory and port number.
 */
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory port:(int)port
{		
	Upload *upload = [[Upload alloc] init];
	
	[upload setProtocol:[self protocolType]];
	[upload setUsername:authUsername];
	[upload setHostname:host];
	[upload setPort:port];
	[upload setDirectory:directory];
	[upload setProgress:0];
	
	[self setTransfer:upload];
	
	[NSThread detachNewThreadSelector:@selector(startRecursiveUpload:)
							 toTarget:self 
						   withObject:filesAndDirectories];
	
	return upload;
}


/*
 * Thread entry point for recursive uploads. Takes in a list of files and directories to be uploaded and uses the info in [self transfer] 
 * to perform the upload. 
 */
- (void)startRecursiveUpload:(NSArray *)filesAndDirectories
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[transfer setStatus:TRANSFER_STATUS_QUEUED];
	[transfer setStatusMessage:@"Queued"];
	
	[self performDelegateSelector:@selector(curl:transferStatusDidChange:)];
	
	NSDictionary *pathDict = [self enumerateFilesForUpload:filesAndDirectories withPrefix:[transfer directory]];
	
	[transfer setTotalFiles:[pathDict count]];
	[transfer setTotalFilesUploaded:0];
	
	NSString *creds = [self credentials];
	curl_easy_setopt(handle, CURLOPT_USERPWD, [creds UTF8String]);

	CURLcode result = -1;
	NSArray *files = [pathDict allKeys];
	for (int i = 0; i < [files count]; i++)
	{
		FILE *fh;
		struct stat finfo;
		curl_off_t fsize;
	
		NSString *currentFile = [files objectAtIndex:i];
		
		[transfer setCurrentFile:[currentFile lastPathComponent]];
		
		if(stat([currentFile UTF8String], &finfo)) 
		{
			NSLog(@"Couldnt open file '%s': %s", currentFile);
			break;
		}
		
		fsize = (curl_off_t)finfo.st_size;
		
		fh = fopen([currentFile UTF8String], "rb");
		
		NSString *url = [NSString stringWithFormat:@"%@://%@:%d/%@", [self protocolPrefix], [transfer hostname], [transfer port], [pathDict valueForKey:currentFile]];
		
		NSLog(@"URL - %@", url);
		
		curl_easy_setopt(handle, CURLOPT_READDATA, fh);
		curl_easy_setopt(handle, CURLOPT_INFILESIZE_LARGE, (curl_off_t)fsize);
		curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
		
		result = curl_easy_perform(handle);
		
		fclose(fh);
		
		if (result != CURLE_OK)
			break;
		
		[transfer setTotalFilesUploaded:[transfer totalFilesUploaded] + 1];
	}
	
	[pathDict release];
	
	curl_easy_cleanup(handle);

	[self setIsUploading:NO];

	[self handleCurlResult:result];

	[pool drain];
	[pool release];
}


/*
 * Enumurates a list of files and directories to be uploaded. Returns a dictionary of files where the key is the absolute path on 
 * the local file system, and the value is the relative remote path.
 *     
 *      e. g. { "/local/path/to/file" => "prefix/remote/path/to/file" }
 */
- (NSDictionary *)enumerateFilesForUpload:(NSArray *)files withPrefix:(NSString *)prefix;
{
	NSMutableArray *localPaths = [[NSMutableArray alloc] init];
	NSMutableArray *remotePaths = [[NSMutableArray alloc] init];
	
	NSFileManager *mgr = [NSFileManager defaultManager];
	
	BOOL isDir;
	for (int i = 0; i < [files count]; i++)
	{
		NSString *pathToFile = [files objectAtIndex:i];
		if ([mgr fileExistsAtPath:pathToFile isDirectory:&isDir] && !isDir)
		{
			[localPaths addObject:pathToFile];
			[remotePaths addObject:[pathToFile lastPathComponent]];
		}
		else
		{
			NSDirectoryEnumerator *dir = [mgr enumeratorAtPath:pathToFile];
			NSString *basePath = [pathToFile lastPathComponent];
			NSString *file;
			
			while (file = [dir nextObject])
			{
				if ([mgr fileExistsAtPath:[pathToFile stringByAppendingPathComponent:file] isDirectory:&isDir] && !isDir)
				{
					[localPaths addObject:[pathToFile stringByAppendingPathComponent:file]];
					[remotePaths addObject:[prefix stringByAppendingPathComponent:[basePath stringByAppendingPathComponent:file]]];
				}
			}
		}
	}
	
	return [[NSDictionary alloc] initWithObjects:remotePaths forKeys:localPaths]; 
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


@end
