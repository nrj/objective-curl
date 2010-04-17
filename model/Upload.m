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


@synthesize localFiles;

@synthesize transfers;

@synthesize currentTransfer;

@synthesize progress;

@synthesize totalFiles;

@synthesize totalFilesUploaded;

@synthesize totalBytes;

@synthesize totalBytesUploaded;

@synthesize lastBytesUploaded;

@synthesize bytesPerSecond;

@synthesize secondsRemaining;


- (id)init
{
	if (self = [super init])
	{
		[self setStatus:0];
		[self setProgress:0];
		[self setTotalFiles:0];
		[self setTotalFilesUploaded:0];
		[self setTotalBytes:0];
		[self setTotalBytesUploaded:0];
		[self setLastBytesUploaded:0];
	}

	return self;
}

- (void)dealloc
{
	[localFiles release];
	[transfers release];
	
	[super dealloc];
}

- (BOOL)isActive
{
	return (status == TRANSFER_STATUS_QUEUED || status == TRANSFER_STATUS_CONNECTING || status == TRANSFER_STATUS_UPLOADING);
}


@end
