//
//  CurlS3.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "CurlS3.h"
#import "CurlClientType.h"
#import "S3ListOperation.h"
#import "S3UploadOperation.h"
#import "Upload.h"
#import "NSString+PathExtras.h"


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


- (int)clientType
{	
	return CURL_CLIENT_S3;
}


- (void)upload:(Upload *)record
{
	[record setProgress:0];
	[record setStatus:TRANSFER_STATUS_QUEUED];
	[record setConnected:NO];
	[record setCancelled:NO];
	
	S3ListOperation *listOperation = [[S3ListOperation alloc] initWithHandle:[self newHandle] delegate:delegate];
	
	S3UploadOperation *uploadOperation = [[S3UploadOperation alloc] initWithHandle:[self newHandle] delegate:delegate];
	
	[listOperation setRequest:record];
	[uploadOperation setUpload:record];
	[uploadOperation addDependency:listOperation];
	
	[operationQueue addOperation:listOperation];
	[operationQueue addOperation:uploadOperation];

	[listOperation release];
	[uploadOperation release];
}


@end
