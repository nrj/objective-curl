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
		
		headers = NULL;
		postQuote = NULL;
		
		percentComplete		= 0;
		totalBytes			= 0;
		totalBytesUploaded	= 0;
	}
	
	return self;
}


- (void)dealloc
{
	[localPath release]; localPath = nil;
	[remotePath release]; remotePath = nil;
	if (headers) {
		curl_slist_free_all(headers); headers = nil;
	}
	if (postQuote) {
		curl_slist_free_all(postQuote); postQuote = nil;
	}
	[super dealloc];
}


- (NSString *)getEmptyFilePath
{
	NSArray *pathComponents = [NSArray arrayWithObjects:[[NSBundle bundleForClass:[self class]] bundlePath], @"Resources", [FileTransfer emptyFilename], NULL];
	
	return [NSString pathWithComponents:pathComponents];
}

- (struct curl_slist *)headers
{
	return headers;
}

- (void)appendHeader:(const char *)header
{
	headers = curl_slist_append(headers, header);
}

- (void)cleanupHeaders
{
	if (headers)
	{
		curl_slist_free_all(headers);
		headers = NULL;
	}
}

- (struct curl_slist *)postQuote
{
	return postQuote;
}

- (void)appendPostQuote:(const char *)quote
{
	postQuote = curl_slist_append(postQuote, quote);
}

- (void)cleanupPostQuotes
{
	if (postQuote)
	{
		curl_slist_free_all(postQuote);
		postQuote = NULL;
	}
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


+ (NSString *)emptyFilename
{
	return @".empty";
}

@end