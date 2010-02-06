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
#import "TransferStatus.h"
#import "UploadDelegate.h"
#import "CurlFTP.h"


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
	
	// Start the recursive upload.
	for (int i = 0; i < [filesToUpload count]; i++)
	{
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
		
		struct curl_slist *commands = NULL;
		if ([file isEmptyDirectory])
		{			
			char *del = malloc(strlen("DELE ") + [TMP_FILENAME length] + 1);
			sprintf(del, "DELE %s", [TMP_FILENAME UTF8String]);
			commands = curl_slist_append(commands, del);
		}
		curl_easy_setopt(handle, CURLOPT_POSTQUOTE, commands);
		
		// Perform
		result = curl_easy_perform(handle);
		
		fclose(fh);
		
		curl_slist_free_all(commands);
		
		if (result != CURLE_OK)
			break;			
		
		[transfer setTotalFilesUploaded:[transfer totalFilesUploaded] + 1];
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
static int handleUploadProgress(FTPUploadOperation *operation, double dltotal, double dlnow, double ultotal, double ulnow)
{	
	Upload *transfer = [operation transfer];
	
	long totalProgressUnits = 100 * ([transfer totalFiles]);
	long individualProgress = ([transfer totalFilesUploaded] * 100) + (ulnow * 100 / ultotal);
	if (ulnow == 0 && ultotal == 0) individualProgress = 100;
	int actualProgress = (individualProgress * 100) / totalProgressUnits;
	
	if ([transfer cancelled])
	{
		// [operation cancel]; ?
		
		
		return -1;
	}
	else if (actualProgress >= 0)
	{
		if (![transfer isUploading])
		{
			[transfer setIsConnecting:NO];
			[transfer setIsUploading:YES];
			
			[transfer setStatus:TRANSFER_STATUS_UPLOADING];
			
			[operation performUploadDelegateSelector:@selector(uploadDidBegin:) 
										withArgument:nil];
		}
		
		if (actualProgress > [transfer progress])
		{
			[transfer setProgress:actualProgress];
			
			[operation performUploadDelegateSelector:@selector(uploadDidProgress:toPercent:) 
										withArgument:[NSNumber numberWithInt:actualProgress]];
		}
	}
	
	return 0;
}


/*
 * Called when the upload loop execution has finished. Updates the state of the upload and notifies delegates.
 *
 */
- (void)handleUploadResult:(CURLcode)result
{
	[transfer setIsUploading:NO];

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
		// Figure out what went wrong, and notify delegate
		[self handleUploadFailed:result];
	}
}



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
 * Takes a list of files and directories and returns an array of PendingTransfer objects.
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
 * Returns the prefix for the protocol being used. In this case "ftp"
 */
- (NSString *)protocolPrefix
{
	return FTP_PROTOCOL_PREFIX;
}


/* 
 * Returns a string that can be used for FTP authentication, "username:password", if no username is specified then "anonymous" will 
 * be used. If a username is present but no password is set, then the users keychain is checked.
 */
- (NSString *)credentials
{
	NSString *creds;
	if ([transfer hasAuthUsername])
	{
		if (![transfer hasAuthPassword])
		{
			// Try Keychain
		}
		
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
 * Cleanup. Release the transfer.
 */
- (void)dealloc
{
	[transfer release];
	
	[super dealloc];
}


@end
