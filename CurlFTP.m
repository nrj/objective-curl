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
		
		curl_easy_setopt(handle, CURLOPT_FTP_CREATE_MISSING_DIRS, 1L);
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


/*
 * Returns the URL prefix for FTP transfers.
 */
- (NSString * const)protocolPrefix
{
	return FTP_PROTOCOL_PREFIX;
}


/*
 * Called by curl when a directory list needs to be written. Takes a pointer to an array that will be filled with RemoteFile objects.
 *
 *     See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTWRITEFUNCTION
 */
static size_t handleDirectoryList(void *ptr, size_t size, size_t nmemb, NSMutableArray *list)
{
	char *line = strtok((char *)ptr, "\n");
	
	do
	{
		struct ftpparse *info = malloc(sizeof(struct ftpparse));
		
		if(line) 
		{	
			if (ftpparse(info, line, strlen(line)))
			{
				char filename[info->namelen + 1];
				strncpy(filename, info->name, info->namelen);
				filename[info->namelen] = '\0';
				
				RemoteFile *file = [[RemoteFile alloc] init];	
				[file setName:[NSString stringWithCString:filename]];
				[file setIsDir:info->flagtrycwd];
				[file setIsSymLink:(info->flagtrycwd && info->flagtryretr)];
				[file setSize:info->size];
				[file setLastModified:info->mtime];
				[file setLastModified:(long)info->mtime];
				
				[list addObject:file];
			}			
		}
		
		line = strtok('\0', "\n");
		free(info);
		
	} while (line);
	
	return (size_t)(size * nmemb);
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
 * Thread entry point for directory listings. Takes a pointer to the RemoteFolder.  
 */
- (void)performListRemoteDirectory:(RemoteFolder *)folder
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *url = [NSString stringWithFormat:@"%@://%@:%d/%@", [self protocolPrefix], 
					 [folder hostname], [folder port], [folder path]];
	
	NSLog(@"Fetching remote directory: %@", url);
	
	NSMutableArray *list;
	
	if ([folder forceReload] || !(list = [directoryListCache objectForKey:url]))
	{
		list = [[NSMutableArray alloc] init];
		
		curl_easy_setopt(handle, CURLOPT_USERPWD, [[self credentials] UTF8String]);
		curl_easy_setopt(handle, CURLOPT_WRITEFUNCTION, handleDirectoryList);
		curl_easy_setopt(handle, CURLOPT_WRITEDATA, list);
		curl_easy_setopt(handle, CURLOPT_UPLOAD, NO);
		curl_easy_setopt(handle, CURLOPT_CUSTOMREQUEST, "LIST");
		curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
		
		CURLcode result = -1;
		
		[folder setStatusMessage:[NSString stringWithFormat:@"Connecting to %@", [folder hostname]]];
		
		result = curl_easy_perform(handle);
		
		[self handleCurlResult:result forObject:folder];

		[directoryListCache setObject:list forKey:url];
	}
	
	[folder setFiles:list];
	
	if (delegate && [delegate respondsToSelector:@selector(curl:didListRemoteDirectory:)])
	{
		[delegate curl:self didListRemoteDirectory:folder];
	}
	
//	[folder release];
	
	[pool drain];
	[pool release];
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
 * Recursively upload a list of files and directories using the specified host, directory and port number.
 */
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory port:(int)port
{		
	Upload *upload = [[Upload alloc] init];
	
	[upload setProtocol:[self protocolType]];
	[upload setHostname:host];
	[upload setPort:port];
	[upload setDirectory:[directory pathForFTP]];
	[upload setProgress:0];
	
	[NSThread detachNewThreadSelector:@selector(performRecursiveUpload:)
							 toTarget:self 
						   withObject:upload];
	
	return upload;
}


/*
 * Thread entry point for recursive uploads. Takes an TransferRecord implementation that  
 */
- (void)performRecursiveUpload:(Upload *)upload
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self checkUploadForOverwrites:[upload localFiles]];
	
	int totalFiles = 0;
	
	NSArray *commands = [self createCommandsForUpload:[upload localFiles] totalFiles:&totalFiles];
	
	[upload setTotalFiles:totalFiles];
	[upload setTotalFilesUploaded:0];
	
	NSString *creds = [self credentials];
	curl_easy_setopt(handle, CURLOPT_USERPWD, [creds UTF8String]);
	
	CURLcode result = -1;
	for (int i = 0; i < [commands count]; i++)
	{
		FTPCommand *cmd = [commands objectAtIndex:i];
		
		[upload setCurrentFile:[[cmd localPath] lastPathComponent]];
		
		NSLog(@"Preparing upload of %@", [upload currentFile]);
		
//		RemoteFile *existing = nil;
//		if (existing = [self remoteFileExists:[upload currentFile] onHost:[upload hostname] atPath:[upload directory] port:[upload port]])
//		{
//			NSLog(@"Existing File Found: %@", [existing description]);	
//		}
//		else
//		{
//			NSLog(@"No Existing File Found");
//		}
			
		/*
		 
		 Temporary until I can get the existing callbacks implemented.
		 */
		if ([cmd type] == FTP_COMMAND_MKDIR)
		{
			char *mkdir = malloc(strlen("MKDIR \"\"") + strlen([[cmd remotePath] UTF8String]) + 1);
			sprintf(mkdir, "MKDIR \"%s\"", [[cmd remotePath] UTF8String]);
			
			NSString *url = [NSString stringWithFormat:@"%@://%@:%d/", [self protocolPrefix], [upload hostname], [upload port]];

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
			
			NSString *url = [NSString stringWithFormat:@"%@://%@:%d/%@%@", [self protocolPrefix], [upload hostname], [upload port], [upload directory], [cmd remotePath]];
			
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
			
			[upload setTotalFilesUploaded:[upload totalFilesUploaded] + 1];
		}
		// */
	}
	
	[commands release];

	[self setIsUploading:NO];
	
	[self handleCurlResult:result forObject:upload];

	[pool drain];
	[pool release];
}


/*
 * Checks the list of files for the upload and informs the delegate if any remote files will be overwritten. 
 */
- (void)checkUploadForOverwrites:(NSArray *)filesAndDirectories
{
	
	
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
