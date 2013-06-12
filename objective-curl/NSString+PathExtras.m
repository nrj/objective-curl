//
//  NSString+PathExtras.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "NSString+PathExtras.h"


@implementation NSString (PathExtras)


- (NSString *)stringByAppendingPathPreservingAbsolutePaths:(NSString *)str
{
	NSMutableString *res = [[self stringByAppendingPathComponent:str] mutableCopy];
	
	if ([[str substringToIndex:1] isEqualToString:@"/"])
	{	
		[res replaceCharactersInRange:[res rangeOfString:@"/"] withString:@"//"];
	}
	
	return (NSString *)res;
}

- (NSString *)stringByAddingTildePrefix
{
	if ([self isEqualToString:@""])
		return @"~/";
	
	NSMutableString *path;
	
	// Not an absolute path, add a tilde prefix.
	if(![[self substringToIndex:1] isEqualToString:@"~"] && ![[self substringToIndex:1] isEqualToString:@"/"])
		path = [NSMutableString stringWithString:[@"~/" stringByAppendingPathComponent:self]];
	else
		path = [NSMutableString stringWithString:self];
	
	return path;
}


- (NSString *)stringByRemovingTildePrefix
{
	if ([[self substringToIndex:2] isEqualToString:@"~/"])
	{
		return [self substringFromIndex:2];
	}
	
	return self;
}


@end
