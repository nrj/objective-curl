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
	[curl setVerbose:NO];
	[curl setShowProgress:YES];
	[curl setAuthUsername:[usernameField stringValue]];
	[curl setAuthPassword:[passwordField stringValue]];
	[curl setDelegate:self];
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


- (void)curl:(CurlSFTP *)client receivedUnknownHostKeyFingerprint:(NSString *)fingerprint
{
	NSAlert *alert = [NSAlert alertWithMessageText:@"Unknown Host Key Fingerprint" 
									 defaultButton:@"Allow" 
								   alternateButton:@"Always" 
									   otherButton:@"Deny" 
						 informativeTextWithFormat:fingerprint];
	
	int answer = [NSApp runModalForWindow:[alert window]];
	
	switch (answer)
	{
		case 1: 
			[client acceptHostKeyFingerprint:fingerprint permanently:NO];
			break;
		case 0:
			[client acceptHostKeyFingerprint:fingerprint permanently:YES];
			break;
		default:
			[client rejectHostKeyFingerprint:fingerprint];
			break;
	}
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