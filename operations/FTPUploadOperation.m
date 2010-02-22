//
//  FTPUploadOperation.m
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import "FTPUploadOperation.h"
#import "NSObject+Extensions.h"
#import "PendingTransfer.h"
#import "Upload.h"
#import "UploadDelegate.h"
#import "TransferStatus.h"

NSString * const FTP_PROTOCOL_PREFIX = @"ftp";
NSString * const TMP_FILENAME = @".objective-curl-tmp";

@implementation FTPUploadOperation

@synthesize transfer;

/*
 * Thread entry point for recursive FTP uploads.
 */
- (void)main 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Transfer Status set to QUEUED.
	[transfer setStatus:TRANSFER_STATUS_QUEUED];
		
	// Set curl options
	curl_easy_setopt(handle, CURLOPT_UPLOAD, 1L);
	curl_easy_setopt(handle, CURLOPT_USERPWD, [[self credentials] UTF8String]);
	curl_easy_setopt(handle, CURLOPT_PROGRESSDATA, self);
	curl_easy_setopt(handle, CURLOPT_PROGRESSFUNCTION, handleUploadProgress);
	
	// Enumurate files and directories to upload
	NSArray *filesToUpload = [[self enumerateFilesToUpload:[transfer localFiles]] retain];

	[transfer setTotalFiles:[filesToUpload count]];
	[transfer setTotalFilesUploaded:0];

	CURLcode result = -1;
	
	for (int i = 0; i < [filesToUpload count]; i++)
	{
		// Begin Uploading.
		
		PendingTransfer *file = [filesToUpload objectAtIndex:i] != [NSNull null] ? [filesToUpload objectAtIndex:i] : nil;
		
		if (!file)
		{
			NSLog(@"Local file not found: %@", [[transfer localFiles] objectAtIndex:i]);
			continue;
		}
		
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
							[transfer hostname], [transfer port], [transfer path], relativePath];
		
		curl_easy_setopt(handle, CURLOPT_READDATA, fh);
		curl_easy_setopt(handle, CURLOPT_INFILESIZE_LARGE, (curl_off_t)fsize);
		curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);

		// If we are trying to upload an empty directory we place an empty file inside of it
		// and create a quote command to clean it up after.
		
		struct curl_slist *postRun = NULL;
		char *removeTempFile = NULL;

		if ([file isEmptyDirectory])
		{			
			postRun = curl_slist_append(postRun, [self removeTempFileCommand:[file remotePath]]);
		}

		// Add quote commands, if any.
		curl_easy_setopt(handle, CURLOPT_POSTQUOTE, postRun);
		
		// Perform
		result = curl_easy_perform(handle);
		
		// Cleanup.
		curl_slist_free_all(postRun);
		free(removeTempFile);
		fclose(fh);
		
		// If this upload wasn't successful, bail out.
		if (result != CURLE_OK)
			break;			
		
		// Increment total files uploaded
		[transfer setTotalFilesUploaded:(i + 1)];
	}
		
	// Cleanup.
	[filesToUpload release];

	// Process the result of the upload.
	[self handleUploadResult:result];
	
	// Done.
	[pool release];
}



/*
 * Used to handle upload progress if the showProgress flag is set. Invoked by libcurl on progress updates to calculates the 
 * new upload progress and sets it on the transfer.
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTPROGRESSFUNCTION 
 */
static int handleUploadProgress(FTPUploadOperation *operation, int connected, double dltotal, double dlnow, double ultotal, double ulnow)
{	
	Upload *transfer = [operation transfer];

	if (!connected)
	{		
		
		if ([transfer status] != TRANSFER_STATUS_CONNECTING)
		{
			// Connecting ...
			[transfer setConnected:NO];
			[transfer setStatus:TRANSFER_STATUS_CONNECTING];

			// Notify the delegate
			[operation performUploadDelegateSelector:@selector(uploadIsConnecting:) withArgument:nil];
		}
		
	}
	else
	{
		
		if (![transfer connected])
		{
			// We have a connection.
			[transfer setConnected:YES];
			[transfer setStatus:TRANSFER_STATUS_UPLOADING];
			
			// Notify the delegate
			[operation performUploadDelegateSelector:@selector(uploadDidBegin:) withArgument:nil];
		}
		
		// Calculate progress
		
		long totalProgress = 100 * [transfer totalFiles];
		long progressNow = (ulnow == 0 && ultotal == 0) ? 
			([transfer totalFilesUploaded] + 1) * 100 : ([transfer totalFilesUploaded] * 100) + (ulnow * 100 / ultotal);
		int percentComplete = (progressNow * 100) / totalProgress;
		
		if (percentComplete > [transfer progress])
		{
			[transfer setProgress:percentComplete];
			
			[operation performUploadDelegateSelector:@selector(uploadDidProgress:toPercent:) 
										withArgument:[NSNumber numberWithInt:percentComplete]];
		}
		
	}	
	
	return [transfer cancelled];
}



/*
 * Called when the upload loop execution has finished. Updates the state of the upload and notifies delegates.
 *
 */
- (void)handleUploadResult:(CURLcode)result
{
	if (result == CURLE_OK && [transfer totalFiles] == [transfer totalFilesUploaded])
	{
		// Success!
		[transfer setStatus:TRANSFER_STATUS_COMPLETE];
		
		// Notify Delegates		
		[self performUploadDelegateSelector:@selector(uploadDidFinish:) 
							   withArgument:nil];
	}
	else if (result == CURLE_ABORTED_BY_CALLBACK)
	{
		// Cancelled!
		[transfer setStatus:TRANSFER_STATUS_CANCELLED];

		// Notify Delegate
		[self performUploadDelegateSelector:@selector(uploadWasCancelled:) 
							   withArgument:nil];
	}
	else
	{		
		// Handle Failure
		[self handleUploadFailed:result];
	}
}



/*
 * Handles a failed upload. Figures out what went wrong and notifies the delegate. 
 *
 */
- (void)handleUploadFailed:(CURLcode)result
{
	// The upload operation failed.
	[transfer setStatus:TRANSFER_STATUS_FAILED];

	NSString *message = [self getFailureDetailsForStatus:result withObject:transfer];
	
	if (result == CURLE_LOGIN_DENIED)
	{
		if (delegate && [delegate respondsToSelector:@selector(uploadDidFailAuthentication:message:)])
		{
			[[delegate invokeOnMainThread] uploadDidFailAuthentication:transfer message:message];
		}
	}
	else
	{
		if (delegate && [delegate respondsToSelector:@selector(uploadDidFail:message:)])
		{
			[[delegate invokeOnMainThread] uploadDidFail:transfer message:message];
		}
	}
}



/*
 * Takes in a list of files and directories to be uploaded, and returns an array of PendingTransfers.
 * 
 */
- (NSArray *)enumerateFilesToUpload:(NSArray *)files
{
	NSMutableArray *filesToUpload = [[NSMutableArray alloc] init];
	NSFileManager *mgr = [NSFileManager defaultManager];
	
	BOOL isDir;
	for (int i = 0; i < [files count]; i++)
	{		
		NSString *pathToFile = [files objectAtIndex:i];
		
		PendingTransfer *info;
		
		if ([mgr fileExistsAtPath:pathToFile isDirectory:&isDir] && !isDir)
		{
			info = [[PendingTransfer alloc] initWithLocalPath:pathToFile remotePath:[pathToFile lastPathComponent]];
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
					info = [[PendingTransfer alloc] initWithLocalPath:nextPath 
									remotePath:[basePath stringByAppendingPathComponent:filename]];

					[filesToUpload addObject:info];
				}
				else if ([[mgr contentsOfDirectoryAtPath:nextPath error:nil] count] == 0)
				{
					info = [[PendingTransfer alloc] initWithLocalPath:nextPath 
									remotePath:[basePath stringByAppendingPathComponent:filename]];

					[info setIsEmptyDirectory:YES];
					
					[filesToUpload addObject:info];
				}
			}
		}
		else if ([mgr fileExistsAtPath:pathToFile])
		{
			info = [[PendingTransfer alloc] initWithLocalPath:pathToFile 
												remotePath:[pathToFile lastPathComponent]];
		
			[info setIsEmptyDirectory:YES];
		}
		else
		{
			info = (id)[NSNull null];
		}
		
		[filesToUpload addObject:info];
	}
	
	return [filesToUpload autorelease];
}



/*
 * Calls an UploadDelegate method on the main thread.
 *
 */
- (void)performUploadDelegateSelector:(SEL)aSelector withArgument:(id)arg
{
	if (delegate && [delegate respondsToSelector:aSelector])
	{
		if (arg)
		{
			[[delegate invokeOnMainThread] performSelector:aSelector withObject:transfer withObject:arg];
		}
		else
		{
			[[delegate invokeOnMainThread] performSelector:aSelector withObject:transfer];
		}
	}
}



/* 
 * Returns a string that can be used for FTP authentication, "username:password", if no username is specified then "anonymous" will 
 * be used. If a username is present but no password is set, then the users keychain is checked.
 *
 */
- (NSString *)credentials
{
	NSString *creds;
	if ([transfer hasAuthUsername])
	{
		creds = [NSString stringWithFormat:@"%@:%@", [transfer username], [transfer password]];
	}
	else
	{
		// Try anonymous login
		creds = [NSString stringWithFormat:@"anonymous:"];
	}
	
	return creds;
}


/*
 * Returns a char pointer containing the delete temp file command. Be sure to call free() on the result.
 *
 */
- (char *)removeTempFileCommand:(NSString *)basePath
{
	char *command = malloc(strlen("DELE ") + [TMP_FILENAME length] + 1);
	sprintf(command, "DELE %s", [TMP_FILENAME UTF8String]);
	return command;
}



/*
 * Returns the prefix for the protocol being used. In this case "ftp"
 *
 */
- (NSString *)protocolPrefix
{
	return FTP_PROTOCOL_PREFIX;
}



/*
 * Cleanup. Release the transfer.
 *
 */
- (void)dealloc
{
	[transfer release];
	
	[super dealloc];
}



@end
