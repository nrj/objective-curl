//
//  CurlSFTP.m
//  objective-curl
//
//  Created by nrj on 12/27/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlSFTP.h"


@implementation CurlSFTP


/*
 * Initializes the class instance for performing FTP uploads. If you don't use this method then you will have to manually set some or all 
 * of these options before doing any uploads
 */
- (id)initForUpload
{		
	if (self = [super initForUpload])
	{
		[self setProtocolType:kSecProtocolTypeSSH];

		curl_easy_setopt(handle, CURLOPT_SSH_KEYFUNCTION, hostKeyCallback);
		curl_easy_setopt(handle, CURLOPT_SSH_KEYDATA, self);
	}
	
	return self;
}


/*
 * Invoked by curl when the known_host key matching is done. Returns a curl_khstat that determines how to proceed. 
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTSSHKEYFUNCTION
 */
int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, void *client)
{
	NSLog(@"Host Key Callback");
	
	
	return 0;
}


/*
 * Set the path to use for the OpenSSH known_hosts file. Default is ~/.ssh/known_hosts
 */
- (void)setKnownHostsFile:(NSString *)filePath
{		
	if (knownHostsFile != filePath)
	{
		[knownHostsFile release];
		knownHostsFile = [filePath copy];		
		curl_easy_setopt(handle, CURLOPT_SSH_KNOWNHOSTS, [knownHostsFile UTF8String]);
	}
}


/*
 * Returns the path set for the OpenSSH known_hosts file.
 */
- (NSString *)knownHostsFile
{
	return knownHostsFile;
}


/*
 * 
 */
- (void)addAcceptedHostKey:(NSString *)hostKey
{
	
}


/*
 *
 */
- (void)addAcceptedHostKey:(NSString *)hostKey toFile:(BOOL)addToFile
{
	
}








/*
 * Recursively upload a list of files and directories using the specified host and the users home directory.
 */
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
								 directory:@""
									  port:DEFAULT_SFTP_PORT];
}


/*
 * Recursively upload a list of files and directories using the specified host and directory.
 */
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory
{
	return [self uploadFilesAndDirectories:filesAndDirectories 
									toHost:host 
								 directory:directory
									  port:DEFAULT_SFTP_PORT];	
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
	
	NSDictionary *pathDict = [self enumerateFilesForUpload:filesAndDirectories withPrefix:[transfer directory]];
	
	[transfer setTotalFiles:[pathDict count]];
	[transfer setTotalFilesUploaded:0];
	
	NSString *creds = [self credentials];
	curl_easy_setopt(handle, CURLOPT_USERPWD, [creds UTF8String]);
	
	CURLcode result = -1;
	NSArray *files = [pathDict allKeys];
	for (int i = 0; i < [files count]; i++)
	{
		FILE *fh;
		struct stat finfo;
		curl_off_t fsize;
		
		NSString *currentFile = [files objectAtIndex:i];
		
		[transfer setCurrentFile:[currentFile lastPathComponent]];
		
		if(stat([currentFile UTF8String], &finfo)) 
		{
			NSLog(@"Couldnt open file '%s': %s", currentFile);
			break;
		}
		
		fsize = (curl_off_t)finfo.st_size;
		
		fh = fopen([currentFile UTF8String], "rb");
		
		NSString *url = [NSString stringWithFormat:@"sftp://%@:%d/%@", [transfer hostname], [transfer port], [pathDict valueForKey:currentFile]];
		
		curl_easy_setopt(handle, CURLOPT_READDATA, fh);
		curl_easy_setopt(handle, CURLOPT_INFILESIZE_LARGE, (curl_off_t)fsize);
		curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
		
		result = curl_easy_perform(handle);
		
		fclose(fh);
		
		if (result != CURLE_OK)
			break;
		
		[transfer setTotalFilesUploaded:[transfer totalFilesUploaded] + 1];
	}
	
	[pathDict release];
	
	curl_easy_cleanup(handle);
	
	[self setIsUploading:NO];
	
	[self handleCurlResult:result];
	
	[pool drain];
	[pool release];
}


@end
