//
//  FTPUploadOperation.m
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import "FTPUploadOperation.h"


NSString * const FTP_PROTOCOL_PREFIX = @"ftp";
NSString * const TMP_FILENAME = @".objective-curl-tmp";

@implementation FTPUploadOperation

@synthesize transfer;


/*
 * Used to handle upload progress if the showProgress flag is set. Invoked by libcurl on progress updates to calculates the 
 * new upload progress and sets it on the transfer.
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTPROGRESSFUNCTION 
 */
static int handleUploadProgress(Upload *transfer, double dltotal, double dlnow, double ultotal, double ulnow)
{	
	if (ultotal == 0) return 0;
	 
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
	 
		// TODO - Notify delegates of progress and update status message here maybe?
	 }
	return 0;
}


/*
 * Thread entry point for recursive FTPUploads.
 */
- (void)main 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Set curl options
	curl_easy_setopt(handle, CURLOPT_UPLOAD, 1L);
	curl_easy_setopt(handle, CURLOPT_FTP_CREATE_MISSING_DIRS, 1L);
	curl_easy_setopt(handle, CURLOPT_PROGRESSDATA, transfer);
	curl_easy_setopt(handle, CURLOPT_PROGRESSFUNCTION, handleUploadProgress);
	
	// Enumurate files and directories to upload
	NSArray *filesToUpload = [[self enumerateFilesToUpload:[transfer localFiles]] retain];

	[transfer setTotalFiles:[filesToUpload count]];
	[transfer setTotalFilesUploaded:0];

	for (int i = 0; i < [filesToUpload count]; i++)
	{
		TransferInfo *file = [filesToUpload objectAtIndex:i];
		
		[transfer setCurrentFile:[[file localPath] lastPathComponent]];
			
		FILE *fh = [file getHandle];
		struct stat finfo;
		
		if ([file getInfo:&finfo])
		{
			NSLog(@"Unable to open file %@", [file localPath]);
			break;
		}
		
		curl_off_t fsize = (curl_off_t)finfo.st_size;
		
		NSString *relativePath = ([file isEmptyDirectory] ? [[file remotePath] stringByAppendingPathComponent:TMP_FILENAME] : [file remotePath]);
		
		NSString *url = [NSString stringWithFormat:@"%@://%@:%d/%@%@", [self protocolPrefix], 
						 [transfer hostname], [transfer port], [transfer directory], relativePath];
		
		curl_easy_setopt(handle, CURLOPT_READDATA, fh);
		curl_easy_setopt(handle, CURLOPT_INFILESIZE_LARGE, (curl_off_t)fsize);
		curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
		
		struct curl_slist *commands = NULL;
		if ([file isEmptyDirectory])
		{			
			char *del = malloc(strlen("DELE ") + [TMP_FILENAME length] + 1);
			sprintf(del, "DELE %s", [TMP_FILENAME UTF8String]);
			commands = curl_slist_append(commands, del);
		}
		curl_easy_setopt(handle, CURLOPT_POSTQUOTE, commands);
		
		CURLcode result = -1;
		
		// Perform
		result = curl_easy_perform(handle);
		
		fclose(fh);
		
		curl_slist_free_all(commands);
		
		if (result != CURLE_OK)
			break;
		
		[transfer setTotalFilesUploaded:[transfer totalFilesUploaded] + 1];
	}
	
//	[self setIsUploading:NO];
//	[self handleCurlResult:result forObject:transfer];

	[filesToUpload release];
	[transfer release];

	[pool drain];
	[pool release];
}


- (NSString *)protocolPrefix
{
	return FTP_PROTOCOL_PREFIX;
}


/*
 * Takes a list of files and directories and returns an array of TransferInfo objects.
 * 
 */
- (NSArray *)enumerateFilesToUpload:(NSArray *)files
{
	NSMutableArray *transfers = [[NSMutableArray alloc] init];
	NSFileManager *mgr = [NSFileManager defaultManager];
	
	BOOL isDir;
	for (int i = 0; i < [files count]; i++)
	{		
		NSString *pathToFile = [files objectAtIndex:i];
		
		TransferInfo *info = NULL;
		
		if ([mgr fileExistsAtPath:pathToFile isDirectory:&isDir] && !isDir)
		{
			info = [[TransferInfo alloc] initWithLocalPath:pathToFile remotePath:[pathToFile lastPathComponent]];
		}
		else if ([[mgr contentsOfDirectoryAtPath:pathToFile error:nil] count] > 0)
		{
			NSDirectoryEnumerator *dir = [mgr enumeratorAtPath:pathToFile];
			NSString *basePath = [pathToFile lastPathComponent];
			NSString *filename = NULL;
			
			while (filename = [dir nextObject])
			{
				NSString *nextPath = [pathToFile stringByAppendingPathComponent:filename];
				
				if ([mgr fileExistsAtPath:nextPath isDirectory:&isDir] && !isDir)
				{
					info = [[TransferInfo alloc] initWithLocalPath:nextPath 
														remotePath:[basePath stringByAppendingPathComponent:filename]];

					[transfers addObject:info];
				}
				else if ([[mgr contentsOfDirectoryAtPath:nextPath error:nil] count] == 0)
				{
					info = [[TransferInfo alloc] initWithLocalPath:nextPath 
														remotePath:[basePath stringByAppendingPathComponent:filename]];

					[info setIsEmptyDirectory:YES];
					
					[transfers addObject:info];
				}
			}
		}
		else
		{
			info = [[TransferInfo alloc] initWithLocalPath:pathToFile 
												remotePath:[pathToFile lastPathComponent]];
			
			[info setIsEmptyDirectory:YES];
		}
		
		[transfers addObject:info];
	}
	
	return [transfers autorelease];
}


@end
