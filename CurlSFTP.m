//
//  CurlSFTP.m
//  objective-curl
//
//  Created by nrj on 12/27/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlSFTP.h"


@implementation CurlSFTP

const int DEFAULT_SFTP_PORT	= 22;
const NSString *DEFAULT_KNOWN_HOSTS	= @"~/.ssh/known_hosts";


/*
 * Initializes the class instance for performing FTP uploads. If you don't use this method then you will have to manually set some or all 
 * of these options before doing any uploads
 */
- (id)initForUpload
{		
	if (self = [super initForUpload])
	{
		[self setProtocolType:kSecProtocolTypeSSH];

		[self setKnownHostsFile:[DEFAULT_KNOWN_HOSTS stringByExpandingTildeInPath]];
		
		hostKeyFingerprints = [[NSMutableDictionary alloc] init];

		curl_easy_setopt(handle, CURLOPT_SSH_KEYFUNCTION, hostKeyCallback);
		curl_easy_setopt(handle, CURLOPT_SSH_KEYDATA, self);
	}
	
	return self;
}


- (void)dealloc
{
	[knownHostsFile release];
	[hostKeyFingerprints release];
	[super dealloc];
}


/*
 * Invoked by curl when the known_host key matching is done. Returns a curl_khstat that determines how to proceed. 
 *
 *      See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTSSHKEYFUNCTION
 */
static int hostKeyCallback(CURL *curl, const struct curl_khkey *knownKey, const struct curl_khkey *foundKey, enum curl_khmatch type, CurlSFTP *client)
{			
	int result = -1;
	NSString *fingerprint = [NSString formattedMD5:foundKey->key length:foundKey->len];
	switch (type)
	{
		case CURLKHMATCH_OK:
			result = CURLKHSTAT_FINE;
			break;
			
		case CURLKHMATCH_MISSING:
			result = [client handleUnknownHostKey:fingerprint];
			break;

		case CURLKHMATCH_MISMATCH:
			result = [client handleMismatchedHostKey:fingerprint];
			break;
			
		default:
			NSLog(@"Unknown curl_khmatch type: %d", type);
			break;
	}
	
	/* 
	 CURLKHSTAT_FINE_ADD_TO_FILE	= OK, and add it to known_hosts
	 CURLKHSTAT_FINE				= OK, but don't add to known_hosts
	 CURLKHSTAT_REJECT				= NOT OK, reject the connection, return an error
	 CURLKHSTAT_DEFER				= NO ANSWER, leave the connection intact til we do
	 */	
	
	return result;
}


/*
 * Search the acceptedHostKeys dictionary for the RSA fingerprint and return accordingly. If it is not found the Inform the delegate 
 * that the host we're trying to connect to has an unknown RSA fingerprint.
 */
- (int)handleUnknownHostKey:(NSString *)rsaFingerprint
{
	int result = CURLKHSTAT_DEFER;

	if (delegate && [delegate respondsToSelector:@selector(curl:transfer:receivedUnknownHostKey:)])
	{
		[delegate curl:self transfer:transfer receivedUnknownHostKey:rsaFingerprint];
	}
	
	for (id key in hostKeyFingerprints)
	{
		if ([rsaFingerprint isEqual:key])
		{
			result = [[hostKeyFingerprints valueForKey:key] intValue];
			break;
		}
	}
	
	return result;
}


/*
 * Search the acceptedHostKeys dictionary for the RSA fingerprint and return accordingly. If it is not found the Inform the delegate 
 * that the host we're trying to connect to has an mismatched RSA fingerprint.
 */		
- (int)handleMismatchedHostKey:(NSString *)rsaFingerprint
{
	int result = CURLKHSTAT_DEFER;

	if (delegate && [delegate respondsToSelector:@selector(curl:transfer:receivedMismatchedHostKey:)])
	{
		[delegate curl:self transfer:transfer receivedMismatchedHostKey:rsaFingerprint];
	}
	
	for (id key in hostKeyFingerprints)
	{
		if ([rsaFingerprint isEqual:key])
		{
			result = [[hostKeyFingerprints valueForKey:key] intValue];
			break;
		}
	}
	
	return result;
}
				

- (void)acceptHostKeyFingerprint:(NSString *)fingerprint permanently:(BOOL)permanent
{
	int status = (permanent ? CURLKHSTAT_FINE_ADD_TO_FILE : CURLKHSTAT_FINE);
	
	[hostKeyFingerprints setObject:[NSNumber numberWithInt:status] 
							forKey:fingerprint];	
}


- (void)rejectHostKeyFingerprint:(NSString *)fingerprint
{
	[hostKeyFingerprints setObject:[NSNumber numberWithInt:CURLKHSTAT_REJECT] 
							forKey:fingerprint];
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
