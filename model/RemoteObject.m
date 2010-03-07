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
@synthesize protocolPrefix;
@synthesize hostname;
@synthesize path;
@synthesize username;
@synthesize password;
@synthesize port;
@synthesize status;
@synthesize cancelled;
@synthesize connected;

@synthesize name;
@synthesize statusMessage;


- (void)dealloc
{
	[protocolPrefix release], protocolPrefix = nil;
	[hostname release], hostname = nil;
	[username release], username = nil;
	[password release], password = nil;
	[path release], path = nil;
	[statusMessage release], statusMessage = nil;
	
	[super dealloc];
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


- (NSString *)uri
{
	return [NSString stringWithFormat:@"%@://%@@%@:%d/%@", protocolPrefix, username, hostname, port, path];
}


@end
