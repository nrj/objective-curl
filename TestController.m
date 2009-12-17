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
	
	[ftp setVerbose:YES];
	[ftp setShowProgress:YES];
	
	[ftp setAuthUsername:@"nrj"];
	[ftp setAuthPassword:@"antiquing"];
	
	NSArray *filesToUpload = [[NSArray alloc] initWithObjects:@"/Users/nrj/Desktop/OneWay", NULL];
	
	[ftp uploadFilesAndDirectories:filesToUpload 
							toHost:@"bender.local" 
							  port:21
						 directory:@"~"];
}


@end