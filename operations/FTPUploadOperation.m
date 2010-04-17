//
//  FTPUploadOperation.m
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import "FTPUploadOperation.h"
#import "NSObject+Extensions.h"
#import "FileTransfer.h"
#import "Upload.h"
#import "UploadDelegate.h"
#import "TransferStatus.h"
#import "NSString+PathExtras.h"


NSString * const TMP_FILENAME = @".objective-curl-tmp";

@implementation FTPUploadOperation

@synthesize upload;


/*
 * Thread entry point for recursive FTP uploads.
 */
- (void)main 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
	// Set curl options
	curl_easy_setopt(handle, CURLOPT_UPLOAD, 1L);
	curl_easy_setopt(handle, CURLOPT_USERPWD, [[self credentials] UTF8String]);
	curl_easy_setopt(handle, CURLOPT_PROGRESSDATA, self);
	curl_easy_setopt(handle, CURLOPT_PROGRESSFUNCTION, handleUploadProgress);
	
	double totalBytes = 0;
	
	// Enumurate files and directories to upload
	NSArray *filesToUpload = [[self enumerateFilesToUpload:[upload localFiles] 
													prefix:[upload path] 
												totalBytes:&totalBytes] retain];
	
	[upload setTransfers:filesToUpload];

	[upload setTotalFiles:[filesToUpload count]];
	[upload setTotalFilesUploaded:0];

	[upload setTotalBytes:totalBytes];
	[upload setTotalBytesUploaded:0];
	
			
	CURLcode result = -1;
	
	for (int i = 0; i < [filesToUpload count]; i++)
	{
		// Begin Uploading.
		FileTransfer *file = [filesToUpload objectAtIndex:i];
		
		[upload setCurrentTransfer:file];
		
		if ([file fileNotFound])
		{
			NSLog(@"Local file not found: %@", [file localPath]);

			continue;
		}
					
		FILE *fh = [file getHandle];
		
		NSString *relativePath = [file isEmptyDirectory] ? [[file remotePath] stringByAppendingPathComponent:TMP_FILENAME] : [file remotePath];
		
		NSString *url = [NSString stringWithFormat:@"%@://%@:%d/%@", [upload protocolPrefix], [upload hostname], [upload port], relativePath];
		
		curl_easy_setopt(handle, CURLOPT_READDATA, fh);
		curl_easy_setopt(handle, CURLOPT_INFILESIZE_LARGE, (curl_off_t)[file totalBytes]);
		curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);

		// If we are trying to upload an empty directory we upload an empty file inside of it
		// and create a quote command to clean it up after.
		
		struct curl_slist *postRun = NULL;
		char *removeTempFile = NULL;

		if ([file isEmptyDirectory])
		{			
			postRun = curl_slist_append(postRun, [self removeTempFileCommand:[relativePath stringByRemovingTildePrefix]]);
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
		[upload setTotalFilesUploaded:i + 1];
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
 * new upload progress and sets it on the upload.
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTPROGRESSFUNCTION 
 */
static int handleUploadProgress(FTPUploadOperation *operation, int connected, double dltotal, double dlnow, double ultotal, double ulnow)
{	
	Upload *upload = [operation upload];
	
	if (!connected)
	{		
		
		if ([upload status] != TRANSFER_STATUS_CONNECTING)
		{
			// Connecting ...
			[upload setConnected:NO];
			[upload setStatus:TRANSFER_STATUS_CONNECTING];

			// Notify the delegate
			[operation performUploadDelegateSelector:@selector(uploadIsConnecting:) withArgument:nil];
		}
		
	}
	else
	{
		if (![upload connected])
		{
			// We have a connection.
			[upload setConnected:YES];
			[upload setStatus:TRANSFER_STATUS_UPLOADING];
			
			// Notify the delegate
			[operation performUploadDelegateSelector:@selector(uploadDidBegin:) withArgument:nil];
			
			// Start the BPS timer
			[operation startByteTimer];
		}
		
		// Compute the current files bytes uploaded
		double currentBytesUploaded = [[upload currentTransfer] isEmptyDirectory] ? [[upload currentTransfer] totalBytes] : ulnow;
		
		// Compute the total bytes uploaded
		double totalBytesUploaded = [upload totalBytesUploaded] + (currentBytesUploaded - [[upload currentTransfer] totalBytesUploaded]);
		
		// Compute current files percentage complete
		double percentComplete = [[upload currentTransfer] isEmptyDirectory] ? 100 : (ulnow * 100 / ultotal);
		
		[[upload currentTransfer] setTotalBytesUploaded:currentBytesUploaded];
		[[upload currentTransfer] setPercentComplete:percentComplete];
		
		[upload setTotalBytesUploaded:totalBytesUploaded];
		
		// Compute the total percent complete of the entire transfer
		int progressNow = ([upload totalBytesUploaded] * 100 / [upload totalBytes]);
						
		if (progressNow > [upload progress])
		{
			// Set the current progress
			[upload setProgress:progressNow];
						
			// Notify the delegate
			[operation performUploadDelegateSelector:@selector(uploadDidProgress:toPercent:) 
										withArgument:[NSNumber numberWithInt:progressNow]];
		}
	}	
	
	return [upload cancelled];
}


/*
 * Called when the upload loop execution has finished. Updates the state of the upload and notifies delegates.
 *
 */
- (void)handleUploadResult:(CURLcode)result
{
	if (result == CURLE_OK && [upload totalFiles] == [upload totalFilesUploaded])
	{
		// Success!
		[upload setStatus:TRANSFER_STATUS_COMPLETE];
		
		// Notify Delegates		
		[self performUploadDelegateSelector:@selector(uploadDidFinish:) 
							   withArgument:nil];
	}
	else if (result == CURLE_ABORTED_BY_CALLBACK)
	{
		// Cancelled!
		[upload setStatus:TRANSFER_STATUS_CANCELLED];

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
	int status;
	switch (result)
	{
		// Auth Failure
		case CURLE_LOGIN_DENIED:
			status = TRANSFER_STATUS_LOGIN_DENIED;
			break;
			
		// General Failure
		default:
			status = TRANSFER_STATUS_FAILED;
			break;
	}
	
	[upload setStatus:status];

	NSString *message = [self getFailureDetailsForStatus:result withObject:upload];
	
	if (delegate && [delegate respondsToSelector:@selector(uploadDidFail:message:)])
	{
		[[delegate invokeOnMainThread] uploadDidFail:upload message:message];
	}
}



/*
 * Takes in a list of files and directories to be uploaded, and returns an array of FileTransfers.
 * 
 */
- (NSArray *)enumerateFilesToUpload:(NSArray *)files prefix:(NSString *)prefix totalBytes:(double *)totalBytes
{
	NSMutableArray *filesToUpload = [[NSMutableArray alloc] init];
	NSFileManager *mgr = [NSFileManager defaultManager];
	
	BOOL isDir;
	for (int i = 0; i < [files count]; i++)
	{		
		NSString *pathToFile = [files objectAtIndex:i];
				
		FileTransfer *pendingTransfer = nil;
		
		if ([mgr fileExistsAtPath:pathToFile isDirectory:&isDir] && !isDir)
		{
			// Regular File
			
			pendingTransfer = [[FileTransfer alloc] initWithLocalPath:pathToFile
									remotePath:[prefix stringByAppendingPathComponent:[pathToFile lastPathComponent]]];
		}
		else if ([[mgr contentsOfDirectoryAtPath:pathToFile error:nil] count] > 0)
		{
			// Non-Empty Directory
			
			NSDirectoryEnumerator *dir = [mgr enumeratorAtPath:pathToFile];
			NSString *basePath = [pathToFile lastPathComponent];
			NSString *filename = NULL;
			
			while (filename = [dir nextObject])
			{
				NSString *nextPath = [pathToFile stringByAppendingPathComponent:filename];
				
				if ([mgr fileExistsAtPath:nextPath isDirectory:&isDir] && !isDir)
				{
					pendingTransfer = [[FileTransfer alloc] initWithLocalPath:nextPath 
										remotePath:[prefix stringByAppendingPathComponent:[basePath stringByAppendingPathComponent:filename]]];
					
				}
				else if ([[mgr contentsOfDirectoryAtPath:nextPath error:nil] count] == 0)
				{
					pendingTransfer = [[FileTransfer alloc] initWithLocalPath:nextPath 
										remotePath:[prefix stringByAppendingPathComponent:[basePath stringByAppendingPathComponent:filename]]];

					[pendingTransfer setIsEmptyDirectory:YES];
				}
				
				[pendingTransfer setTotalBytes:[[[mgr fileAttributesAtPath:[pendingTransfer localPath] 
															  traverseLink:YES] objectForKey:NSFileSize] doubleValue]];
				
				// Add to totalBytes
				*totalBytes += [pendingTransfer totalBytes];
				
				[filesToUpload addObject:pendingTransfer];				
			}
			
			continue;
		}
		else
		{
			pendingTransfer = [[FileTransfer alloc] initWithLocalPath:pathToFile 
								remotePath:[prefix stringByAppendingPathComponent:[pathToFile lastPathComponent]]];
			
			if ([mgr fileExistsAtPath:pathToFile])
			{
				// Empty Directory
				[pendingTransfer setIsEmptyDirectory:YES];
			}
			else
			{
				// Not Found	
				[pendingTransfer setFileNotFound:YES];
			}
		}
		
		[pendingTransfer setTotalBytes:[[[mgr fileAttributesAtPath:[pendingTransfer localPath] 
													  traverseLink:YES] objectForKey:NSFileSize] doubleValue]];
		
		// Add to totalBytes
		*totalBytes += [pendingTransfer totalBytes];
		
						
		[filesToUpload addObject:pendingTransfer];
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
			[[delegate invokeOnMainThread] performSelector:aSelector withObject:upload withObject:arg];
		}
		else
		{
			[[delegate invokeOnMainThread] performSelector:aSelector withObject:upload];
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
	if ([upload hasAuthUsername])
	{
		creds = [NSString stringWithFormat:@"%@:%@", [upload username], [upload password]];
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
- (char *)removeTempFileCommand:(NSString *)tmpFilePath
{
	char *command = malloc(strlen("DELE ") + [TMP_FILENAME length] + 1);
	sprintf(command, "DELE %s", [TMP_FILENAME UTF8String]);
	return command;
}


/*
 * Cleanup. Release the upload.
 *
 */
- (void)dealloc
{
	[upload release];
	
	[super dealloc];
}


- (void)startByteTimer
{
	NSThread* timerThread = [[NSThread alloc] initWithTarget:self 
													selector:@selector(enterByteTimerThread) 
													  object:nil];
	[timerThread start];
}


- (void)enterByteTimerThread
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	
	[[NSTimer scheduledTimerWithTimeInterval:2.0
									  target:self
									selector:@selector(calculateBytesPerSecond:)
									userInfo:nil
									 repeats:YES] retain];
	
	[runLoop run];
	[pool release];
}


- (void)calculateBytesPerSecond:(NSTimer *)timer
{
	if ([upload isActive])
	{
		double bps = [upload totalBytesUploaded] - [upload lastBytesUploaded];
		double sr  = ([upload totalBytes] - [upload totalBytesUploaded]) / bps;
		
		[upload setBytesPerSecond:bps];
		[upload setSecondsRemaining:sr];
		[upload setLastBytesUploaded:[upload totalBytesUploaded]];
	}
	else
	{
		[timer invalidate];
	}
}


@end
