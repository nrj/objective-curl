//
//  TestController.m
//  objective-curl
//
//  Created by nrj on 12/7/09.
//  Copyright 2009. All rights reserved.
//

#import "TestController.h"
#import "CurlFTP.h"


@implementation TestController


- (IBAction)runTest:(id)sender
{
	CurlFTP *ftp = [[CurlFTP alloc] init];

//	[ftp setVerbose:YES];
	[ftp setShowProgress:YES];
	
	[ftp setAuthUsername:@"nrj"];
	[ftp setAuthPassword:@"antiquing"];
	[ftp setDelegate:self];
	
	NSArray *filesToUpload = [[NSArray alloc] initWithObjects:@"/Users/nrj/Desktop/OneWay", NULL];
	
	[ftp uploadFilesAndDirectories:filesToUpload 
							toHost:@"bender.local" 
							  port:21
						 directory:@"/home/nrj/global"];
	
	
		

	[ftp setDelegate:self];
	
}

- (void)curl:(CurlObject *)client transferFailedAuthentication:(id <TransferRecord>)aRecord
{
	NSLog(@"transferFailedAuthentication");
}

- (void)curl:(CurlObject *)client transferDidBegin:(id <TransferRecord>)aRecord
{
	NSLog(@"transferDidBegin", [aRecord progress]);	
}

- (void)curl:(CurlObject *)client transferDidProgress:(id <TransferRecord>)aRecord
{
	NSLog(@"transferDidProgress %d", [aRecord progress]);
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