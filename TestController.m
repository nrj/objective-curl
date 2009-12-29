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
}

- (IBAction)runTest:(id)sender
{	
	CurlSFTP *sftp = [[CurlSFTP alloc] initForUpload];

	[sftp setVerbose:YES];
	[sftp setShowProgress:YES];
	[sftp setAuthUsername:@"nrj"];
	[sftp setAuthPassword:@"yaynocops"];

	[sftp setDelegate:self];
	
	NSArray *filesToUpload = [[NSArray alloc] initWithObjects:@"/Users/nrj/Desktop/fugu-1.2.0", NULL];
		
	id <TransferRecord>newUpload = [sftp uploadFilesAndDirectories:filesToUpload 
															toHost:@"localhost" 
														 directory:@"~/tmp"];
	
	[self setUpload:newUpload];
}

- (void)curl:(CurlObject *)client transferFailedAuthentication:(id <TransferRecord>)aRecord
{
	//NSLog(@"transferFailedAuthentication");
}

- (void)curl:(CurlObject *)client transferDidBegin:(id <TransferRecord>)aRecord
{
	//NSLog(@"transferDidBegin");	
}

- (void)curl:(CurlObject *)client transferDidProgress:(id <TransferRecord>)aRecord
{
	//NSLog(@"transferDidProgress - %@", [aRecord statusMessage]);
}

- (void)curl:(CurlObject *)client transferDidFinish:(id <TransferRecord>)aRecord
{
	//NSLog(@"transferDidFinish");
}

- (void)curl:(CurlObject *)client transferStatusDidChange:(id <TransferRecord>)aRecord
{
	NSLog(@"transferStatusDidChange %d - %@", [aRecord status], [aRecord statusMessage]);
}

@end