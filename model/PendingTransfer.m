//
//  PendingTransfer.m
//  objective-curl
//
//  Created by nrj on 1/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PendingTransfer.h"


@implementation PendingTransfer

@synthesize localPath;
@synthesize remotePath;
@synthesize isEmptyDirectory;

- (id)initWithLocalPath:(NSString *)aLocalPath remotePath:(NSString *)aRemotePath
{
	if (self = [super init])
	{
		[self setLocalPath:aLocalPath];
		[self setRemotePath:aRemotePath];
		[self setIsEmptyDirectory:NO];
	}
	
	return self;
}

- (FILE *)getHandle
{
	FILE *fh = NULL;
	
	if ([self isEmptyDirectory])
	{
		fh = fopen(NULL_DEVICE, "rb");
	}
	else
	{
		fh = fopen([localPath UTF8String], "rb");
	}

	return fh;
}

- (int)getInfo:(struct stat *)info
{	
	if([self isEmptyDirectory])
	{
		return stat(NULL_DEVICE, info);
	}
	else
	{
		return stat([localPath UTF8String], info);
	}
}

@end