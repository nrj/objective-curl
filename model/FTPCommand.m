//
//  FTPCommand.m
//  objective-curl
//
//  Created by nrj on 1/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FTPCommand.h"


@implementation FTPCommand

@synthesize type;
@synthesize localPath;
@synthesize remotePath;

- (id)initWithType:(FTPCommandType)aType localPath:(NSString *)aLocalPath remotePath:(NSString *)aRemotePath
{
	if (self = [super init])
	{
		[self setType:aType];
		[self setLocalPath:aLocalPath];
		[self setRemotePath:aRemotePath];
	}
	
	return self;
}

- (NSString *)text
{
		return @"";
}

@end
