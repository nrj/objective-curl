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
	
	ftp = [[CurlFTP alloc] init];
	
	[ftp setVerbose:YES];
	[ftp setShowProgress:YES];
	
	[ftp setAuthUsername:@"nrj"];
	[ftp setAuthPassword:@"yaynocops"];
	
	[ftp setDelegate:self];
	
	[self runCurlTest];
}

- (void)runCurlTest
{		
	NSArray *filesToUpload = [[NSArray alloc] initWithObjects:@"/Users/nrj/Desktop/skreemr", NULL];
	
	id <TransferRecord>newUpload = [ftp uploadFilesAndDirectories:filesToUpload 
														   toHost:@"localhost" 
															 port:21
														directory:@"tmp"
													  maxConnects:5];
	
	[self setUpload:newUpload];
}

- (void)curl:(CurlObject *)client transferFailedAuthentication:(id <TransferRecord>)aRecord
{
//	NSLog(@"transferFailedAuthentication");
}

- (void)curl:(CurlObject *)client transferDidBegin:(id <TransferRecord>)aRecord
{
//	NSLog(@"transferDidBegin");	
}

- (void)curl:(CurlObject *)client transferDidProgress:(id <TransferRecord>)aRecord
{
//	NSLog(@"transferDidProgress - %@", [aRecord statusMessage]);
}

- (void)curl:(CurlObject *)client transferDidFinish:(id <TransferRecord>)aRecord
{
//	NSLog(@"transferDidFinish");
}

- (void)curl:(CurlObject *)client transferStatusDidChange:(id <TransferRecord>)aRecord
{
//	NSLog(@"transferStatusDidChange %d - %@", [aRecord status], [aRecord statusMessage]);
}

@end