//
//  CurlFTP.m
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlFTP.h"
#import "Upload.h"


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
	
	[self setCurrentTransfer:upload];
	
	[NSThread detachNewThreadSelector:@selector(performUploadOnNewThread:) 
							 toTarget:self 
						   withObject:remoteFiles];
	
	return upload;
}

@end


#pragma mark Private Methods


@implementation CurlFTP (Private)


- (void)performUploadOnNewThread:(NSArray *)remoteFiles
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	CURLcode result;
	FILE *fh;
	struct stat file_info;
	curl_off_t fsize;

	NSString *credentials = [NSString stringWithFormat:@"%@:%@", authUsername, authPassword];

	curl_easy_setopt(handle, CURLOPT_UPLOAD, 1L);
	curl_easy_setopt(handle, CURLOPT_USERPWD, [credentials UTF8String]);
	curl_easy_setopt(handle, CURLOPT_FTP_CREATE_MISSING_DIRS, 1);

	NSArray *localFiles = [currentTransfer localFiles];
	
	for (int i = 0; i < [localFiles count]; i++)
	{
		NSString *localFile = [localFiles objectAtIndex:i];
		NSString *remoteFile = [remoteFiles objectAtIndex:i];
		
		if(stat([localFile UTF8String], &file_info)) {
			printf("Couldnt open '%s': %s\n", [localFile UTF8String], strerror(errno));
			break;
		}
		
		fsize = (curl_off_t)file_info.st_size;
		
		fh = fopen([localFile UTF8String], "rb");
		
		char remoteUrl[1024];
		sprintf(remoteUrl, "ftp://%s:%d/%s", [[currentTransfer hostname] UTF8String], [currentTransfer port], [remoteFile UTF8String]);
		
		curl_easy_setopt(handle, CURLOPT_URL, remoteUrl);
		curl_easy_setopt(handle, CURLOPT_READDATA, fh);
		curl_easy_setopt(handle, CURLOPT_INFILESIZE_LARGE, (curl_off_t)fsize);		
		
		result = curl_easy_perform(handle);
		
		if (result != CURLE_OK)
			break;
		
		fclose(fh);
	}

	[remoteFiles release];
	
	curl_easy_cleanup(handle);
	
	[pool drain];
	[pool release];
}


@end