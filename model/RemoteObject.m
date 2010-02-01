//
//  RemoteObject.m
//  objective-curl
//
//  Created by nrj on 1/4/10.
//  Copyright 2010. All rights reserved.
//

#import "RemoteObject.h"


@implementation RemoteObject 

// TODO - create - (void)handleFailedRemoteOperation:(CurlOperation *)operation withObject:(id <ThisProtocol>)object
// TODO - invoke a delegate method with the failed operation, message, and object. 
// TODO - add a retryOperation: method to CurlObject which will add it back to the queue

@synthesize hostname;
@synthesize username;
@synthesize password;
@synthesize path;
@synthesize protocol;
@synthesize port;
@synthesize status;

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
