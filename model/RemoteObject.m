//
//  RemoteObject.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "RemoteObject.h"


@implementation RemoteObject 

@synthesize protocol;
@synthesize protocolPrefix;
@synthesize hostname;
@synthesize port;
@synthesize path;
@synthesize url;

@synthesize clientType;

@synthesize username;
@synthesize password;

@synthesize usePublicKeyAuth;
@synthesize canUsePublicKeyAuth;
@synthesize privateKeyFile;
@synthesize publicKeyFile;

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
	[privateKeyFile release], privateKeyFile = nil;
	[publicKeyFile release], publicKeyFile = nil;
	[path release], path = nil;
	[url release], url = nil;
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
