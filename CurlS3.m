//
//  CurlS3.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "CurlS3.h"
#import "S3UploadOperation.h"
#import "Upload.h"

@implementation CurlS3


- (id)init
{		
	if (self = [super init])
	{
		[self setProtocol:kSecProtocolTypeHTTPS];
	}
	
	return self;
}


- (NSString *)protocolPrefix
{
	return @"https";
}


- (int)defaultPort
{
	return 443;
}


- (void)upload:(Upload *)record
{
	S3UploadOperation *op = [[S3UploadOperation alloc] initWithHandle:[self newHandle] delegate:delegate];
	
	[record setProgress:0];
	[record setStatus:TRANSFER_STATUS_QUEUED];
	[record setConnected:NO];
	[record setCancelled:NO];
	
	[op setUpload:record];
	[operationQueue addOperation:op];
	[op release];
}


@end
