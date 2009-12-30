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

- (void)awakeFromNib
{
	[progress setUsesThreadedAnimation:YES];
	
	filesToUpload = [[NSArray alloc] initWithObjects:[@"~/Desktop/test-upload" stringByExpandingTildeInPath], NULL];
}

- (IBAction)runSFTPTest:(id)sender
{	
	CurlSFTP *sftp = [[CurlSFTP alloc] initForUpload];

	[sftp setVerbose:NO];
	[sftp setShowProgress:YES];
	
	[sftp setAuthUsername:[usernameField stringValue]];
	[sftp setAuthPassword:[passwordField stringValue]];

	[sftp setDelegate:self];
			
	id <TransferRecord>newUpload = [sftp uploadFilesAndDirectories:filesToUpload 
															toHost:@"localhost" 
														 directory:@"~/"];
	
	[self setUpload:newUpload];
}

- (IBAction)runFTPTest:(id)sender
{	
	CurlFTP *ftp = [[CurlFTP alloc] initForUpload];
	
	[ftp setVerbose:NO];
	[ftp setShowProgress:YES];
	
	[ftp setAuthUsername:[usernameField stringValue]];
	[ftp setAuthPassword:[passwordField stringValue]];
	
	[ftp setDelegate:self];
	
	id <TransferRecord>newUpload = [ftp uploadFilesAndDirectories:filesToUpload 
															toHost:@"localhost" 
														 directory:@"~/"];
	
	[self setUpload:newUpload];
}

- (void)curl:(CurlObject *)client transferFailedAuthentication:(id <TransferRecord>)aRecord
{	
	NSLog(@"transferFailedAuthentication");
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
}

- (void)curl:(CurlObject *)client transferStatusDidChange:(id <TransferRecord>)aRecord
{
	NSLog(@"transferStatusDidChange %d - %@", [aRecord status], [aRecord statusMessage]);
}

@end