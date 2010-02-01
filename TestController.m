//
//  TestController.m
//  objective-curl
//
//  Created by nrj on 12/7/09.
//  Copyright 2009. All rights reserved.
//

#import "TestController.h"


@implementation TestController

@synthesize folder;
@synthesize upload;


- (void)awakeFromNib
{		
	NSLog([CurlObject libcurlVersion]);
	
	[fileView setDataSource:self];
	[fileView setDelegate:self];
	[fileView setDoubleAction:@selector(navigateRemoteDirectory:)];
	
	sftp = [[CurlSFTP alloc] init];
}


- (void)initCurlObject:(CurlObject *)curl
{	
	[curl setVerbose:YES];
	[curl setShowProgress:YES];
	[curl setDelegate:self];
}


- (IBAction)uploadFile:(id)sender
{
	[self initCurlObject:sftp];
	
	NSString *file = [[fileField stringValue] stringByExpandingTildeInPath];
	
	Upload *newUpload = [sftp uploadFilesAndDirectories:[NSArray arrayWithObjects:file, NULL]  
												 toHost:[hostnameField stringValue] 
											   username:[usernameField stringValue] 
											   password:[passwordField stringValue]];
	
	[self setUpload:newUpload];
}


- (IBAction)listRemoteDirectory:(id)sender
{
	[self initCurlObject:sftp];
	
	NSString *hostname = [hostnameField stringValue];
	
	RemoteFolder *remoteFolder = [sftp listRemoteDirectory:@"" onHost:hostname];
	
	[self setFolder:remoteFolder];
}


- (IBAction)navigateRemoteDirectory:(id)sender
{
	if (folder && [fileView clickedRow] != -1)
	{
		RemoteFile *file = (RemoteFile*)[[folder files] objectAtIndex:[fileView clickedRow]];
		
		if ([file isDir])
		{
			NSString *newPath = [[folder path] appendPathForFTP:[file name]];
			[self setFolder:[sftp listRemoteDirectory:newPath onHost:[folder hostname]]];
		}
	}
}


- (void)curl:(CurlObject *)client didListRemoteDirectory:(RemoteFolder *)dir
{
	[fileView reloadData];
}


#pragma mark SSHDelegate methods


- (int)acceptUnknownFingerprint:(NSString *)fingerprint forHost:(NSString *)hostname
{
	NSLog(@"acceptUnknownFingerprint: %@ forHost: %@", fingerprint, hostname);
	
	return 0;
}


- (int)acceptMismatchedFingerprint:(NSString *)fingerprint forHost:(NSString *)hostname
{
	NSLog(@"acceptMismatchedFingerprint: %@ forHost: %@", fingerprint, hostname);
	
	return 0;
}


#pragma mark UploadDelegate methods


- (void)uploadDidBegin:(Upload *)record
{
	NSLog(@"uploadDidBegin");
}


- (void)uploadDidProgress:(Upload *)record toPercent:(NSNumber *)percent;
{
	NSLog(@"uploadDidProgress - %@", percent);	
}


- (void)uploadDidFinish:(Upload *)record
{
	NSLog(@"uploadDidFinish");
}


- (void)uploadWasCancelled:(Upload *)record
{
	NSLog(@"uploadWasCancelled");
}


- (void)uploadDidFailAuthentication:(Upload *)record client:(id <UploadClient>)client message:(NSString *)message;
{
	NSLog(@"uploadDidFailAuthentication: %@", message);
	
	[client retryUpload:upload];
}


- (void)uploadDidFail:(Upload *)record client:(id <UploadClient>)client message:(NSString *)message;
{
	NSLog(@"uploadDidFail: %@", message);
}


#pragma mark TableView Delegate methods


- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if (folder && [folder files] != NULL)
	{
		return [[folder files] count];
	}
	
	return 0;
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if (folder && [folder files] != NULL)
	{
		RemoteFile *file = (RemoteFile *)[[folder files] objectAtIndex:rowIndex];
		return [file name];
	}
	return nil;
}


@end