//
//  S3ListOperation.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "S3ListOperation.h"
#import "S3ErrorParser.h"


@implementation S3ListOperation



@synthesize request;

@synthesize errorCode;

@synthesize errorMessage;



static size_t handleResponse(void *ptr, size_t size, size_t nmemb, S3ListOperation *op)
{			
    return 0;
}


- (void)main
{	
	[self cancel];
}


@end
