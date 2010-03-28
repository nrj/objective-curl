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

@synthesize currentFile;

@synthesize progressInfo;

@synthesize progress;

@synthesize totalFiles;

@synthesize totalFilesUploaded;

@synthesize lastBytesUploaded;

@synthesize totalBytes;

@synthesize totalBytesUploaded;

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
	}

	return self;
}

- (void)dealloc
{
	[localFiles release];
	[currentFile release];

	if (progressInfo)
	{
		[progressInfo release];
	}
	
	[super dealloc];
}

- (void)initProgressInfo
{	
	progressInfo = [[NSMutableArray alloc] initWithCapacity:totalFiles];
	
	for (int i = 0; i < totalFiles; i++)
	{
		[progressInfo addObject:[NSNumber numberWithDouble:0]];
	}
}

- (void)updateProgressInfo
{
	double tbu = 0;
	
	for (int i = 0; i < [progressInfo count]; i++)
	{
		tbu += [[progressInfo objectAtIndex:i] doubleValue];
	}
	
	[self setTotalBytesUploaded:tbu];
}

- (BOOL)isActive
{
	return (status == TRANSFER_STATUS_QUEUED || status == TRANSFER_STATUS_CONNECTING || status == TRANSFER_STATUS_UPLOADING);
}


@end
