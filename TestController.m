//
//  TestController.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "TestController.h"



@implementation TestController

@synthesize upload;


- (void)awakeFromNib
{	
	NSLog(@"Version: %@", [CurlObject libcurlVersion]);
	
	ftp = [[CurlFTP alloc] init];
	[ftp setVerbose:NO];
	[ftp setShowProgress:YES];
	[ftp setDelegate:self];	
	
	sftp = [[CurlSFTP alloc] init];
	[sftp setVerbose:NO];
	[sftp setShowProgress:YES];
	[sftp setDelegate:self];
	
//	scp = [[CurlSCP alloc] init];
//	[scp setVerbose:YES];
//	[scp setShowProgress:YES];
//	[scp setDelegate:self];
	
	s3 = [[CurlS3 alloc] init];
	[s3 setVerbose:YES];
	[s3 setShowProgress:YES];
	[s3 setDelegate:self];
}


- (IBAction)uploadFile:(id)sender
{
	NSString *file = [[fileField stringValue] stringByExpandingTildeInPath];
	
	id <CurlClient>client = nil;
	
	switch([typeSelector selectedRow])
	{
		default:
		case 0:
			client = (id <CurlClient>)sftp;
			break;
		case 1:
			client = (id <CurlClient>)ftp;
			break;
		case 2:
			client = (id <CurlClient>)scp;
			break;
		case 3:
			client = (id <CurlClient>)s3;
			break;
	}

	Upload *newUpload = [client uploadFilesAndDirectories:[NSArray arrayWithObjects:file, NULL]
												   toHost:[hostnameField stringValue] 
												 username:[usernameField stringValue]
												 password:[passwordField stringValue]
												directory:[remoteDirField stringValue]];
	
//	[newUpload setUsePublicKeyAuth:YES];
//	[newUpload setPrivateKeyFile:[@"~/.ssh/id_rsa" stringByExpandingTildeInPath]];
//	[newUpload setPublicKeyFile:[@"~/.ssh/id_rsa.pub" stringByExpandingTildeInPath]];
	
	NSLog(@"Upload Base URI = %@", [newUpload uri]);
	
	[self setUpload:newUpload];
}



#pragma mark ConnectionDelegate methods


- (void)curlIsConnecting:(RemoteObject *)record
{
	NSLog(@"curlIsConnecting");
}

- (void)curlDidConnect:(RemoteObject *)record
{
	NSLog(@"curlDidConnect");
}


#pragma mark UploadDelegate methods


- (void)uploadDidBegin:(Upload *)record
{
	NSLog(@"uploadDidBegin");
}


- (void)uploadDidProgress:(Upload *)record toPercent:(NSNumber *)percent;
{
/*
	NSLog(@".");
	NSLog(@"  Current File: %.0f of %.0f Bytes Uploaded (%d%%)", 
			[[record currentTransfer] totalBytesUploaded], [[record currentTransfer] totalBytes], [[record currentTransfer] percentComplete]);
	
	NSLog(@"Total Progress: %.0f of %.0f Bytes Uploaded (%d%%)", 
			[record totalBytesUploaded], [record totalBytes], [record progress]);
*/
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