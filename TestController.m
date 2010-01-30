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
	
	ftp = [[CurlFTP alloc] init];
}


- (void)initCurlObject:(CurlObject *)curl
{	
	[curl setVerbose:NO];
	[curl setShowProgress:YES];
	[curl setAuthUsername:[usernameField stringValue]];
	[curl setAuthPassword:[passwordField stringValue]];
	[curl setDelegate:self];
}


- (IBAction)uploadFile:(id)sender
{
	[self initCurlObject:ftp];
	
	NSString *file = [[fileField stringValue] stringByExpandingTildeInPath];
	
	Upload *newUpload = [ftp uploadFilesAndDirectories:[NSArray arrayWithObjects:file, NULL] toHost:[hostnameField stringValue]];
	
	[self setUpload:newUpload];
}


- (IBAction)listRemoteDirectory:(id)sender
{
	[self initCurlObject:ftp];
	
	NSString *hostname = [hostnameField stringValue];
	
	RemoteFolder *remoteFolder = [ftp listRemoteDirectory:@"" onHost:hostname];
	
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
			[self setFolder:[ftp listRemoteDirectory:newPath onHost:[folder hostname]]];
		}
	}
}


- (void)curl:(CurlObject *)client didListRemoteDirectory:(RemoteFolder *)dir
{
	[fileView reloadData];
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


- (void)uploadDidFail:(Upload *)record withStatus:(NSString *)message
{
	NSLog(@"uploadDidFail - %@", message);
}


- (void)uploadWasCancelled:(Upload *)record
{
	NSLog(@"uploadWasCancelled");
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


//- (void)curl:(CurlSFTP *)client receivedUnknownHostKeyFingerprint:(NSString *)fingerprint
//{
//	NSAlert *alert = [NSAlert alertWithMessageText:@"Unknown Host Key Fingerprint" 
//									 defaultButton:@"Allow" 
//								   alternateButton:@"Always" 
//									   otherButton:@"Deny" 
//						 informativeTextWithFormat:fingerprint];
//	
//	int answer = [NSApp runModalForWindow:[alert window]];
//	
//	switch (answer)
//	{
//		case 1: 
//			[client acceptHostKeyFingerprint:fingerprint permanently:NO];
//			break;
//		case 0:
//			[client acceptHostKeyFingerprint:fingerprint permanently:YES];
//			break;
//		default:
//			[client rejectHostKeyFingerprint:fingerprint];
//			break;
//	}
//}


@end