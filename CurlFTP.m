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


/*
 * Private Methods
 */
@implementation CurlFTP (Private)


static CurlFTP *_client = NULL;

static size_t parseFTPHeader(void *ptr, size_t size, size_t nmemb, void *data)
{	
	char code[4];
	
	strncpy(code, (char *)ptr, 3);
	
	[_client handleFTPResponse:atoi(code)];
	
	return size * nmemb;
}


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


/*
 * Main Implementation
 */
@implementation CurlFTP


- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host port:(int)port directory:(NSString *)directory
{		
	NSMutableArray *remoteFiles = [[NSMutableArray alloc] init];
	NSMutableArray *localFiles = [[NSMutableArray alloc] init];
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
	
	[localFiles release];
	
	[self setTransfer:upload];
	
	[NSThread detachNewThreadSelector:@selector(performUploadOnNewThread:) 
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


@end
