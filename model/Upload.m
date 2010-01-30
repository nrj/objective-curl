//
//  Upload.m
//  objective-curl
//
//  Created by nrj on 8/25/09.
//  Copyright 2009. All rights reserved.
//

#import "Upload.h"
#import "TransferStatus.h"


@implementation Upload

@synthesize name;
@synthesize directory;
@synthesize localFiles;
@synthesize progress;
@synthesize totalFiles;
@synthesize totalFilesUploaded;
@synthesize currentFile;
@synthesize isUploading;
@synthesize cancelled;

- (id)init
{
	if (self = [super init])
	{
		[self setStatus:0];
		[self setProgress:0];
		[self setTotalFiles:0];
		[self setTotalFilesUploaded:0];
	}

	return self;
}

- (void)dealloc
{
	[name release];
	[localFiles release];
	[hostname release];
	[directory release];
	[currentFile release];
	[super dealloc];
}

- (BOOL)isActiveTransfer
{
	return (status == TRANSFER_STATUS_QUEUED || status == TRANSFER_STATUS_UPLOADING);
}

@end
