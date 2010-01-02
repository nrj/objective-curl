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
								 directory:@""
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
	
	int totalFiles = 0;
	NSArray *commands = [self createCommandsForUpload:filesAndDirectories totalFiles:&totalFiles];
	
	[transfer setTotalFiles:totalFiles];
	[transfer setTotalFilesUploaded:0];
	
	NSString *creds = [self credentials];
	curl_easy_setopt(handle, CURLOPT_USERPWD, [creds UTF8String]);
	
	CURLcode result = -1;
	for (int i = 0; i < [commands count]; i++)
	{
		FTPCommand *cmd = [commands objectAtIndex:i];
		
		[transfer setCurrentFile:[[cmd localPath] lastPathComponent]];
		
		if ([cmd type] == FTP_COMMAND_MKDIR)
		{
			char *mkdir = malloc(strlen("MKDIR \"\"") + strlen([[cmd remotePath] UTF8String]) + 1);
			sprintf(mkdir, "MKDIR \"%s\"", [[cmd remotePath] UTF8String]);
			
			NSString *url = [NSString stringWithFormat:@"%@://%@:%d/", [self protocolPrefix], [transfer hostname], [transfer port]];

			struct curl_slist *headers = NULL; 
			headers = curl_slist_append(headers, mkdir); 

			curl_easy_setopt(handle, CURLOPT_UPLOAD, 0);
			curl_easy_setopt(handle, CURLOPT_QUOTE, headers); 
			curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
			
			// Perform
			result = curl_easy_perform(handle);

			// Cleanup
			curl_slist_free_all(headers);
			headers = NULL;
			free(mkdir);
			mkdir = NULL;
			
			if (result != CURLE_OK)
				break;
		}
		else if ([cmd type] == FTP_COMMAND_PUT)
		{
			FILE *fh;
			struct stat finfo;
			curl_off_t fsize;
			
			if(stat([[cmd localPath] UTF8String], &finfo)) 
			{
				NSLog(@"Couldnt open file '%@'", [cmd localPath]);
				break;
			}
			
			fsize = (curl_off_t)finfo.st_size;
			
			fh = fopen([[cmd localPath] UTF8String], "rb");
			
			NSString *url = [NSString stringWithFormat:@"%@://%@:%d/%@%@", [self protocolPrefix], [transfer hostname], [transfer port], [transfer directory], [cmd remotePath]];
			
			curl_easy_setopt(handle, CURLOPT_UPLOAD, 1L);
			curl_easy_setopt(handle, CURLOPT_QUOTE, NULL);
			curl_easy_setopt(handle, CURLOPT_READDATA, fh);
			curl_easy_setopt(handle, CURLOPT_INFILESIZE_LARGE, (curl_off_t)fsize);
			curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
			
			// Perform
			result = curl_easy_perform(handle);
			
			fclose(fh);
			
			if (result != CURLE_OK)
				break;
			
			[transfer setTotalFilesUploaded:[transfer totalFilesUploaded] + 1];
		}
	}
	
	[commands release];
	
	curl_easy_cleanup(handle);

	[self setIsUploading:NO];

	[self handleCurlResult:result];

	[pool drain];
	[pool release];
}


/*
 * Enumurates a list of FTP commands needed to perform the upload and returns them in an array.
 */
- (NSArray *)createCommandsForUpload:(NSArray *)files totalFiles:(int *)totalFiles
{
	NSFileManager *mgr = [NSFileManager defaultManager];
	NSMutableArray *commands = [[NSMutableArray alloc] init];
	BOOL isDir;
	for (int i = 0; i < [files count]; i++)
	{
		NSString *pathToFile = [files objectAtIndex:i];
		if ([mgr fileExistsAtPath:pathToFile isDirectory:&isDir] && !isDir)
		{
			FTPCommand *put = [[FTPCommand alloc] initWithType:FTP_COMMAND_PUT 
													 localPath:pathToFile 
													remotePath:[pathToFile lastPathComponent]];
			[commands addObject:put];
			
			*totalFiles += 1;
		}
		else
		{
			NSDirectoryEnumerator *dir = [mgr enumeratorAtPath:pathToFile];
			NSString *basePath = [pathToFile lastPathComponent];
			NSString *file;
			
			FTPCommand *mkdir = [[FTPCommand alloc] initWithType:FTP_COMMAND_MKDIR 
													   localPath:pathToFile 
													  remotePath:basePath];
			
			[commands addObject:mkdir];
			
			while (file = [dir nextObject])
			{
				if ([mgr fileExistsAtPath:[pathToFile stringByAppendingPathComponent:file] isDirectory:&isDir] && !isDir)
				{
					FTPCommand *put = [[FTPCommand alloc] initWithType:FTP_COMMAND_PUT 
															 localPath:[pathToFile stringByAppendingPathComponent:file] 
															remotePath:[basePath stringByAppendingPathComponent:file]];
					[commands addObject:put];
					
					*totalFiles += 1;
				}
				else
				{
					FTPCommand *mkdir = [[FTPCommand alloc] initWithType:FTP_COMMAND_MKDIR
															   localPath:[pathToFile stringByAppendingPathComponent:file] 
															  remotePath:[basePath stringByAppendingPathComponent:file]];
					[commands addObject:mkdir];
				}
			}
		}
	}
	
	return commands;
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
