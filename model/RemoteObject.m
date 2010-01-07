//
//  RemoteObject.m
//  objective-curl
//
//  Created by nrj on 1/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RemoteObject.h"


@implementation RemoteObject

@synthesize protocol;
@synthesize hostname;
@synthesize port;
@synthesize status;
@synthesize statusMessage;

- (void)dealloc
{
	[hostname release];
	[statusMessage release];
	
	[super dealloc];
}

- (NSString *)protocolString
{
	return [[[NSFileTypeForHFSTypeCode(protocol) stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]] 
			 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
}

@end
