//
//  TestController.m
//  objective-curl
//
//  Created by nrj on 12/7/09.
//  Copyright 2009. All rights reserved.
//

#import "TestController.h"


@implementation TestController


@synthesize upload;
@synthesize uploadEnabled;

- (void)awakeFromNib
{
	[progress setUsesThreadedAnimation:YES];
	
	[self setUploadEnabled:YES];
	
	[versionLabel setStringValue:[CurlObject libcurlVersion]];
	
	NSLog([CurlObject libcurlVersion]);
}


- (void)initCurlObject:(CurlObject *)curl
{
	[self setUploadEnabled:NO];
	
	[curl setVerbose:NO];
	[curl setShowProgress:YES];
	[curl setAuthUsername:[usernameField stringValue]];
	[curl setAuthPassword:[passwordField stringValue]];
	
	[curl setDelegate:self];
}


- (IBAction)runDirListTest:(id)sender
{
	CurlSFTP *sftp = [[CurlSFTP alloc] init];
	
	[self initCurlObject:sftp];
	
	NSString *hostname = [hostnameField stringValue];
	NSString *dir = @"~/";
	
	NSArray *directoryList = [sftp listRemoteDirectory:dir onHost:hostname];
	
	for (int i = 0; i < [directoryList count]; i++)
	{
		NSLog([[directoryList objectAtIndex:i] description]);
	}
}


- (IBAction)runSFTPTest:(id)sender
{	
	[self setUploadEnabled:NO];
	
	CurlSFTP *sftp = [[CurlSFTP alloc] init];

	[self initCurlObject:sftp];
	
	NSString *hostname = [hostnameField stringValue];
	NSArray *filesToUpload = [NSArray arrayWithObjects:[[filepathField stringValue] stringByExpandingTildeInPath], NULL];
	
	id <TransferRecord>newUpload = [sftp uploadFilesAndDirectories:filesToUpload toHost:hostname directory:@"asdf"];
	
	[self setUpload:newUpload];
}



- (IBAction)runFTPTest:(id)sender
{	
	[self setUploadEnabled:NO];
	
	CurlFTP *ftp = [[CurlFTP alloc] init];
	
	[self initCurlObject:ftp];
	
	NSString *hostname = [hostnameField stringValue];
	NSArray *filesToUpload = [NSArray arrayWithObjects:[[filepathField stringValue] stringByExpandingTildeInPath], NULL];
	
	id <TransferRecord>newUpload = [ftp uploadFilesAndDirectories:filesToUpload toHost:hostname];
	
	[self setUpload:newUpload];
}


- (IBAction)cancelTransfer:(id)sender
{
	if (![upload hasBeenCancelled])
	{
		[upload setHasBeenCancelled:YES];
	}
}


- (void)curl:(CurlSFTP *)client transfer:(id <TransferRecord>)aRecord receivedUnknownHostKey:(NSString *)fingerprint
{
	NSLog(@"receivedUnknownHostKey: %@", fingerprint);
	
	[client acceptHostKeyFingerprint:fingerprint permanently:NO];

//	[client acceptHostKeyFingerprint:fingerprint permanently:YES];

//	[client rejectHostKeyFingerprint:fingerprint];
}



- (void)curl:(CurlSFTP *)client transfer:(id <TransferRecord>)aRecord receivedMismatchedHostKey:(NSString *)fingerprint
{
	NSLog(@"receivedMismatchedHostKey: %@", fingerprint);
}



- (void)curl:(CurlObject *)client transferFailedAuthentication:(id <TransferRecord>)aRecord
{	
	NSLog(@"transferFailedAuthentication");
	
	[self setUploadEnabled:YES];
}



- (void)curl:(CurlObject *)client transferDidBegin:(id <TransferRecord>)aRecord
{
	NSLog(@"transferDidBegin");	
}



- (void)curl:(CurlObject *)client transferDidProgress:(id <TransferRecord>)aRecord
{
	NSLog(@"transferDidProgress - %d", [aRecord progress]);
}



- (void)curl:(CurlObject *)client transferDidFinish:(id <TransferRecord>)aRecord
{
	NSLog(@"transferDidFinish");
	
	[self setUploadEnabled:YES];
}



- (void)curl:(CurlObject *)client transferStatusDidChange:(id <TransferRecord>)aRecord
{
	NSLog(@"transferStatusDidChange %d - %@", [aRecord status], [aRecord statusMessage]);
	
	if ([aRecord status] == TRANSFER_STATUS_FAILED || [aRecord status] == TRANSFER_STATUS_CANCELLED)
	{
		
		[self setUploadEnabled:YES];
	}
}


@end