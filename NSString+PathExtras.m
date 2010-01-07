//
//  NSString+PathExtras.m
//  objective-curl
//
//  Created by nrj on 1/6/10.
//  Copyright 2010. All rights reserved.
//

#import "NSString+PathExtras.h"


@implementation NSString (PathExtras)

- (NSString *)pathForFTP
{
	if ([self isEqualToString:@""])
		return @"~/";
	
	NSMutableString *path;
	
	// Not an absolute path, add a tilde prefix.
	if(![[self substringToIndex:1] isEqualToString:@"~"] && ![[self substringToIndex:1] isEqualToString:@"/"])
		path = [NSMutableString stringWithString:[@"~/" stringByAppendingPathComponent:self]];
	else
		path = [NSMutableString stringWithString:self];
	
	// SFTP requires a trailing slash.
	if(![[path substringFromIndex:([path length] - 1)] isEqualToString:@"/"])
		[path appendString:@"/"];
	
	return path;
}

- (NSString *)appendPathForFTP:(NSString *)path;
{
	if ([path isEqualToString:@"."])
		return self;
	
	return [[self stringByAppendingPathComponent:path] pathForFTP];
}

@end
