//
//  UploadOperation.m
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import "UploadOperation.h"


@implementation UploadOperation

@synthesize transfer;


/*
 * Used to handle upload progress if the showProgress flag is set. Invoked by libcurl on progress updates to calculates the 
 * new upload progress and sets it on the transfer.
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTPROGRESSFUNCTION 
 */
static int handleCurlProgress(Upload *transfer, double dltotal, double dlnow, double ultotal, double ulnow)
{	
	/*
	 if (ultotal == 0) return 0;
	 
	 //	id <TransferRecord>transfer = [client transfer];
	 
	 long totalProgressUnits = 100 * ([transfer totalFiles]);
	 long individualProgress = ([transfer totalFilesUploaded] * 100) + (ulnow * 100 / ultotal);
	 int actualProgress = (individualProgress * 100) / totalProgressUnits;
	 
	 if ([transfer hasBeenCancelled])
	 {		
	 return -1;
	 }
	 else if (actualProgress >= 0 && actualProgress > [transfer progress])
	 {
	 [transfer setProgress:actualProgress];
	 
	 //		[transfer setStatusMessage:[NSString stringWithFormat:@"Uploading", actualProgress, [transfer hostname]]];
	 
	 //		[client performDelegateSelector:@selector(curl:transferDidProgress:) withObject:transfer];
	 }
	 */	
	return 0;
}


- (void)main 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	int totalFiles = 0;

	NSArray *commands = [[self createCommandsForUpload:[transfer localFiles] totalFiles:&totalFiles] retain];

	[transfer setTotalFiles:totalFiles];
	[transfer setTotalFilesUploaded:0];

	curl_easy_setopt(handle, CURLOPT_USERPWD, [[self credentials] UTF8String]);

	CURLcode result = -1;

	for (int i = 0; i < [commands count]; i++)
	{
		FTPCommand *cmd = [commands objectAtIndex:i];
		
		[transfer setCurrentFile:[[cmd localPath] lastPathComponent]];
		
		NSLog(@"Preparing transfer of %@", [transfer currentFile]);
		
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
		}
		
		[transfer setTotalFilesUploaded:[transfer totalFilesUploaded] + 1];
	}

	[self setIsUploading:NO];

	[self handleCurlResult:result forObject:transfer];

	[commands release];
	[transfer release];

	[pool drain];
	[pool release];
}


/*
 * Enumurates a list of FTP commands needed to perform the transfer and returns them in an array.
 */
- (NSArray *)createCommandsForUpload:(NSArray *)files totalFiles:(int *)totalFiles
{
	NSFileManager *mgr = [NSFileManager defaultManager];
	NSMutableArray *commands = [[NSMutableArray alloc] init];
	BOOL isDir;
	for (int i = 0; i < [files count]; i++)
	{
		*totalFiles += 1;
		
		NSString *pathToFile = [files objectAtIndex:i];
		
		if ([mgr fileExistsAtPath:pathToFile isDirectory:&isDir] && !isDir)
		{
			FTPCommand *put = [[FTPCommand alloc] initWithType:FTP_COMMAND_PUT 
													 localPath:pathToFile 
													remotePath:[pathToFile lastPathComponent]];
			[commands addObject:put];
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
				}
				else
				{
					FTPCommand *mkdir = [[FTPCommand alloc] initWithType:FTP_COMMAND_MKDIR
															   localPath:[pathToFile stringByAppendingPathComponent:file] 
															  remotePath:[basePath stringByAppendingPathComponent:file]];
					[commands addObject:mkdir];
				}
				
				*totalFiles += 1;
			}
		}
	}
	
	return [commands autorelease];
}


@end
