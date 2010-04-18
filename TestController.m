//
//  TestController.m
//  objective-curl
//
//  Created by nrj on 12/7/09.
//  Copyright 2009. All rights reserved.
//

#import "TestController.h"
#import <objective-curl/objective-curl.h>


@implementation TestController

@synthesize upload;


- (void)awakeFromNib
{		
	NSLog([CurlObject libcurlVersion]);
	
	ftp = [[CurlFTP alloc] init];
	[ftp setVerbose:NO];
	[ftp setShowProgress:YES];
	[ftp setDelegate:self];	
	
	sftp = [[CurlSFTP alloc] init];
	[sftp setVerbose:NO];
	[sftp setShowProgress:YES];
	[sftp setDelegate:self];
}


- (IBAction)uploadFile:(id)sender
{
	NSString *file = [[fileField stringValue] stringByExpandingTildeInPath];
	
	id <CurlClient>client = [typeSelector selectedRow] == 0 ? (id <CurlClient>)sftp : (id <CurlClient>)ftp;
	
	Upload *newUpload = [client uploadFilesAndDirectories:[NSArray arrayWithObjects:file, NULL]
												   toHost:[hostnameField stringValue] 
												 username:[usernameField stringValue]
												 password:[passwordField stringValue]
												directory:@"tmp"];
	
	NSLog(@"Upload Base URI = %@", [newUpload uri]);
	
	[self setUpload:newUpload];
}


#pragma mark UploadDelegate methods


- (void)uploadIsConnecting:(Upload *)record
{
	NSLog(@"uploadIsConnecting");
}


- (void)uploadDidBegin:(Upload *)record
{
	NSLog(@"uploadDidBegin");
}


- (void)uploadDidProgress:(Upload *)record toPercent:(NSNumber *)percent;
{
	NSLog(@".");
	//	NSLog(@"Uploading %d of %d Files", [upload totalFilesUploaded], [upload totalFiles]);
	NSLog(@"  Current File: %.0f of %.0f Bytes Uploaded (%d%%)", 
			[[record currentTransfer] totalBytesUploaded], [[record currentTransfer] totalBytes], [[record currentTransfer] percentComplete]);
	
	NSLog(@"Total Progress: %.0f of %.0f Bytes Uploaded (%d%%)", 
			[record totalBytesUploaded], [record totalBytes], [record progress]);
	NSLog(@"");
}


- (void)uploadDidFinish:(Upload *)record
{
	NSLog(@"uploadDidFinish");
}


- (void)uploadWasCancelled:(Upload *)record
{
	NSLog(@"uploadWasCancelled");
}


- (void)uploadDidFail:(Upload *)record message:(NSString *)message;
{
	NSLog(@"uploadDidFail: %@", message);
}


- (int)acceptUnknownHostFingerprint:(NSString *)fingerprint forUpload:(NSString *)record
{
	NSLog(@"acceptUnknownHostFingerprint: %@", fingerprint);
	
	return 0;
}


- (int)acceptMismatchedHostFingerprint:(NSString *)fingerprint forUpload:(NSString *)record
{
	NSLog(@"acceptMismatchedHostFingerprint: %@", fingerprint);
	
	return 0;
}


@end