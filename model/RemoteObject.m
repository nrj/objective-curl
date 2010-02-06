//
//  RemoteObject.m
//  objective-curl
//
//  Created by nrj on 1/4/10.
//  Copyright 2010. All rights reserved.
//

#import "RemoteObject.h"


@implementation RemoteObject 

@synthesize protocol;
@synthesize hostname;
@synthesize path;
@synthesize username;
@synthesize password;
@synthesize port;
@synthesize status;
@synthesize isConnecting;
@synthesize cancelled;

- (void)dealloc
{
	[hostname release], hostname = nil;
	[username release], username = nil;
	[password release], password = nil;
	[path release], path = nil;
	
	[super dealloc];
}

- (NSString *)protocolString
{
	return [[[NSFileTypeForHFSTypeCode(protocol) stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]] 
			 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
}

/*
 * Convenience function... do we have a username set for auth?
 */
- (BOOL)hasAuthUsername
{
	return (username != NULL && ![username isEqualToString:@""]);
}


/*
 * Convenience function... do we have a password set for auth?
 */
- (BOOL)hasAuthPassword
{
	return (password != NULL && ![password isEqualToString:@""]);
}


@end
