//
//  CurlFTP.m
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlFTP.h"
#import "TransferStatus.h"
#import "FTPResponse.h"
#import "Upload.h"


#pragma mark Private Methods


@implementation CurlFTP (Private)


static CurlFTP *_client = NULL;

static size_t parseFTPHeader(void *ptr, size_t size, size_t nmemb, void *data)
{	
	char code[4];
	
	strncpy(code, (char *)ptr, 3);
	
	[_client handleFTPResponse:atoi(code)];
	
	return size * nmemb;
}


/* 
 * Experiemental! Upload a list of files recursively using multiple connections.
 */
- (void)performMultiUploadOnNewThread:(NSArray *)remoteFiles
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *localFiles = [transfer localFiles];
	const int TOTAL_UPLOADS = [localFiles count];
	const int MAX_CONNECTS = 5;

	CURLM *multi_handle = curl_multi_init();
	CURL *handles[MAX_CONNECTS];
	
	curl_multi_setopt(multi_handle, CURLMOPT_MAXCONNECTS, MAX_CONNECTS);
	
	NSString *credentials;
	if ([self hasAuthUsername])
	{
		if (![self hasAuthPassword])
		{
			// Try Keychain
		}
		
		credentials = [NSString stringWithFormat:@"%@:%@", authUsername, authPassword];
	}
	else
	{
		// Try anonymous login
		credentials = [NSString stringWithFormat:@"anonymous:"];
	}	
	
	int count = 0;
	for (count = 0; count < MAX_CONNECTS; ++count)
	{
		FILE *file_handle;
		struct stat file_info;
		curl_off_t file_size;
		
		NSString *localFile = [localFiles objectAtIndex:count];
		NSString *remoteFile = [remoteFiles objectAtIndex:count];
		
		if(stat([localFile UTF8String], &file_info)) {
			NSLog(@"Couldnt open file '%@': %s", localFile, strerror(errno));
			break;
		}
		
		file_size = (curl_off_t)file_info.st_size;
		file_handle = fopen([localFile UTF8String], "rb");
		
		NSString *url = [NSString stringWithFormat:@"ftp://%@:%d/%@", [transfer hostname], [transfer port], remoteFile];

		handles[count] = [self newUploadHandle:url withCredentials:credentials];
		
		file_handle = fopen([localFile UTF8String], "rb");
		
		curl_easy_setopt(handles[count], CURLOPT_READDATA, file_handle);
		curl_easy_setopt(handles[count], CURLOPT_INFILESIZE_LARGE, (curl_off_t)file_size);
			
		curl_multi_add_handle(multi_handle, handles[count]);
	}
	
	
	int still_running = -1;	

	while (still_running)
	{
		while (CURLM_CALL_MULTI_PERFORM == curl_multi_perform(multi_handle, &still_running));
			
		if (still_running)
		{
			struct timeval timeout;
			int maxfd;
			fd_set fdread, fdwrite, fdexc;
			
			FD_ZERO(&fdread);
			FD_ZERO(&fdwrite);
			FD_ZERO(&fdexc);
			
			if(curl_multi_fdset(multi_handle, &fdread, &fdwrite, &fdexc, &maxfd))
			{
				fprintf(stderr, "Error: curl_multi_fdset\n");
				break;
			}

			timeout.tv_sec = 1;
			timeout.tv_usec = 0;

			if (0 > select(maxfd+1, &fdread, &fdwrite, &fdexc, &timeout)) {
				fprintf(stderr, "Error: select()\n");
				break;
			}
		}
		
		int msg_queue;
		CURLMsg *msg = NULL;

		while ((msg = curl_multi_info_read(multi_handle, &msg_queue))) {
			if (msg->msg == CURLMSG_DONE) {
				char *url;
				CURL *easy_handle = msg->easy_handle;
				curl_easy_getinfo(msg->easy_handle, CURLINFO_PRIVATE, &url);
				curl_multi_remove_handle(multi_handle, easy_handle);
				curl_easy_cleanup(easy_handle);
			}
			else {
				fprintf(stderr, "E: CURLMsg (%d)\n", msg->msg);
			}
			if (count < TOTAL_UPLOADS) 
			{
				// --
				FILE *file_handle;
				struct stat file_info;
				curl_off_t file_size;
				
				NSString *localFile = [localFiles objectAtIndex:count];
				NSString *remoteFile = [remoteFiles objectAtIndex:count];
				
				if(stat([localFile UTF8String], &file_info)) {
					NSLog(@"Couldnt open file '%@': %s", localFile, strerror(errno));
					break;
				}
				
				file_size = (curl_off_t)file_info.st_size;
				file_handle = fopen([localFile UTF8String], "rb");
				
				NSString *url = [NSString stringWithFormat:@"ftp://%@:%d/%@", [transfer hostname], [transfer port], remoteFile];
				
				handles[count] = [self newUploadHandle:url withCredentials:credentials];
				
				file_handle = fopen([localFile UTF8String], "rb");
				
				curl_easy_setopt(handles[count], CURLOPT_READDATA, file_handle);
				curl_easy_setopt(handles[count], CURLOPT_INFILESIZE_LARGE, (curl_off_t)file_size);
				
				curl_multi_add_handle(multi_handle, handles[count]);
				
				// --
				count++;
				
				still_running++;
			}
		}
		
	}
			
	curl_multi_cleanup(multi_handle);
	curl_global_cleanup();
	
	[pool drain];
	[pool release];
}


/*
 * Uploads a list of files recursively using 1 connection.
 */
- (void)performUploadOnNewThread:(NSArray *)remoteFiles
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	CURLcode result = -1;
	FILE *fh;
	struct stat file_info;
	curl_off_t fsize;
	
	NSString *credentials;
	if ([self hasAuthUsername])
	{
		if (![self hasAuthPassword])
		{
			// Try Keychain
		}
		
		credentials = [NSString stringWithFormat:@"%@:%@", authUsername, authPassword];
	}
	else
	{
		// Try anonymous login
		credentials = [NSString stringWithFormat:@"anonymous:"];
	}
	
	curl_easy_setopt(handle, CURLOPT_USERPWD, [credentials UTF8String]);		
	curl_easy_setopt(handle, CURLOPT_UPLOAD, 1L);
	curl_easy_setopt(handle, CURLOPT_FTP_CREATE_MISSING_DIRS, 1);
	curl_easy_setopt(handle, CURLOPT_HEADER, 1);
	curl_easy_setopt(handle, CURLOPT_HEADERFUNCTION, parseFTPHeader);
	
	_client = self;
	
	NSArray *localFiles = [transfer localFiles];
	
	for (int i = 0; i < [localFiles count]; i++)
	{
		NSString *localFile = [localFiles objectAtIndex:i];
		NSString *remoteFile = [remoteFiles objectAtIndex:i];
		
		[transfer setCurrentFile:[localFile lastPathComponent]];
		
		if(stat([localFile UTF8String], &file_info)) {
			printf("Couldnt open '%s': %s\n", [localFile UTF8String], strerror(errno));
			break;
		}
		
		fsize = (curl_off_t)file_info.st_size;
		
		fh = fopen([localFile UTF8String], "rb");
		
		char remoteUrl[1024];
		sprintf(remoteUrl, "ftp://%s:%d/%s", [[transfer hostname] UTF8String], [transfer port], [remoteFile UTF8String]);
		
		curl_easy_setopt(handle, CURLOPT_URL, remoteUrl);
		curl_easy_setopt(handle, CURLOPT_READDATA, fh);
		curl_easy_setopt(handle, CURLOPT_INFILESIZE_LARGE, (curl_off_t)fsize);
		
		result = curl_easy_perform(handle);
		
		fclose(fh);
		
		if (result != CURLE_OK)
			break;
	}
	
	_client = NULL;
	
	[remoteFiles release];
	
	curl_easy_cleanup(handle);
	
	[self setIsUploading:NO];
	
	[self handleCurlResult:result];
	
	[pool drain];
	[pool release];
}


@end


#pragma mark Main Implementation


@implementation CurlFTP


- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
									  port:DEFAULT_FTP_PORT 
								 directory:@"" 
							   maxConnects:DEFAULT_MAX_CONNECTS];
}


- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host port:(int)port
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
									  port:port 
								 directory:@"" 
							   maxConnects:DEFAULT_MAX_CONNECTS];	
}


- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host port:(int)port directory:(NSString *)directory
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
									  port:port 
								 directory:directory 
							   maxConnects:DEFAULT_MAX_CONNECTS];
}


- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host port:(int)port directory:(NSString *)directory maxConnects:(int)maxConnects
{		
	NSMutableArray *localFiles = [[NSMutableArray alloc] init];
	NSMutableArray *remoteFiles = [[NSMutableArray alloc] init];

	NSFileManager *mgr = [NSFileManager defaultManager];
	
	BOOL isDir;
	int totalFiles = 0;
	for (int i = 0; i < [filesAndDirectories count]; i++)
	{
		NSString *localPath = [filesAndDirectories objectAtIndex:i];
		if ([mgr fileExistsAtPath:localPath isDirectory:&isDir] && !isDir)
		{
			[localFiles addObject:localPath];
			[remoteFiles addObject:[localPath lastPathComponent]];
			
			++totalFiles;
		}
		else
		{
			NSDirectoryEnumerator *dir = [mgr enumeratorAtPath:localPath];
			NSString *remotePath = [localPath lastPathComponent];
			NSString *file;
			
			while (file = [dir nextObject])
			{
				if ([mgr fileExistsAtPath:[localPath stringByAppendingPathComponent:file] isDirectory:&isDir] && !isDir)
				{
					[localFiles addObject:[localPath stringByAppendingPathComponent:file]];
					[remoteFiles addObject:[directory stringByAppendingPathComponent:[remotePath stringByAppendingPathComponent:file]]];
					++totalFiles;
				}
			}
		}
	}
	
	Upload *upload = [[Upload alloc] init];
	
	[upload setUsername:authUsername];
	[upload setHostname:host];
	[upload setPort:port];
	[upload setDirectory:directory];
	[upload setProgress:0];
	[upload setTotalFilesUploaded:0];
	[upload setLocalFiles:localFiles];
	[upload setTotalFiles:[localFiles count]];
	[upload setMaxConnections:maxConnects];
	
	[localFiles release];
	
	[self setTransfer:upload];

	SEL uploadSelector;
	if (maxConnects > 1)
	{
		uploadSelector = @selector(performMultiUploadOnNewThread:);
	}
	else
	{
		uploadSelector = @selector(performUploadOnNewThread:);
	}
		
	[NSThread detachNewThreadSelector:uploadSelector 
							 toTarget:self 
						   withObject:remoteFiles];
	
	[transfer setStatus:TRANSFER_STATUS_CONNECTING];
	[transfer setStatusMessage:[NSString stringWithFormat:@"Connecting to %@...", host]];
	[self performDelegateSelector:@selector(curl:transferStatusDidChange:)];
	
	return upload;
}


- (void)handleFTPResponse:(int)code
{	
	switch (code)
	{			
		case FTP_RESPONSE_NEED_PASSWORD:
			[transfer setStatus:TRANSFER_STATUS_AUTHENTICATING];
			[transfer setStatusMessage:[NSString stringWithFormat:[NSString stringWithFormat:@"Authenticating %@@%@...", 
			  ([self hasAuthUsername] ? [self authUsername] : @"anonymous"), [transfer hostname]]]];
			[self performDelegateSelector:@selector(curl:transferStatusDidChange:)];
			break;
			
		case FTP_RESPONSE_READY_FOR_DATA:
			if (!isUploading)
			{
				[transfer setStatus:TRANSFER_STATUS_UPLOADING];
				[transfer setStatusMessage:[NSString stringWithFormat:@"Uploading (%d%%) to %@", [transfer progress], [transfer hostname]]];
				[self performDelegateSelector:@selector(curl:transferStatusDidChange:)];
				[self performDelegateSelector:@selector(curl:transferDidBegin:)];
				[self setIsUploading:YES];
			}			
			break;
			
		case FTP_RESPONSE_FILE_RECEIVED:
			[transfer setTotalFilesUploaded:[transfer totalFilesUploaded] + 1];
			break;

		// Could do more notifications here... just these for now though.
			
		default:
			break;
	}
}


- (CURL *)newUploadHandle:(NSString *)url withCredentials:(NSString *)credentials
{
	CURL *easy_handle = curl_easy_init();
	
	curl_easy_setopt(easy_handle, CURLOPT_UPLOAD, 1L);
	curl_easy_setopt(easy_handle, CURLOPT_FTP_CREATE_MISSING_DIRS, 1);
	curl_easy_setopt(easy_handle, CURLOPT_HEADER, 1);
	curl_easy_setopt(easy_handle, CURLOPT_HEADERFUNCTION, parseFTPHeader);
	curl_easy_setopt(easy_handle, CURLOPT_URL, [url UTF8String]);
	curl_easy_setopt(easy_handle, CURLOPT_USERPWD, [credentials UTF8String]);
	curl_easy_setopt(easy_handle, CURLOPT_VERBOSE, YES);
	curl_easy_setopt(easy_handle, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_WHATEVER);
	
	return easy_handle;
}


@end
