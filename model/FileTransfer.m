//
//  FileTransfer.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "FileTransfer.h"


@implementation FileTransfer


@synthesize localPath;

@synthesize remotePath;

@synthesize isEmptyDirectory;

@synthesize percentComplete;

@synthesize totalBytes;

@synthesize totalBytesUploaded;

@synthesize fileNotFound;


- (id)initWithLocalPath:(NSString *)aLocalPath remotePath:(NSString *)aRemotePath
{
	if (self = [super init])
	{
		[self setLocalPath:aLocalPath];
		[self setRemotePath:aRemotePath];
		
		percentComplete		= 0;
		totalBytes			= 0;
		totalBytesUploaded	= 0;
	}
	
	return self;
}

- (NSString *)getEmptyFilePath
{
	NSString *str = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Frameworks/objective-curl.framework/Resources/.empty"];
	
	return str;
}

- (FILE *)getHandle
{
	FILE *fh = NULL;
	
	if ([self isEmptyDirectory])
	{
		fh = fopen([[self getEmptyFilePath] UTF8String], "rb");
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
		return stat([[self getEmptyFilePath] UTF8String], info);
	}
	else
	{
		return stat([localPath UTF8String], info);
	}
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<FileTransfer localPath='%@' remotePath='%@' isEmptyDirectory='%d'", localPath, remotePath, isEmptyDirectory];
}

@end