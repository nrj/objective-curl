//
//  CurlRemoteFolder.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "CurlRemoteFolder.h"


@implementation CurlRemoteFolder


/*
 * Array of CurlRemoteFile objects.
 */
@synthesize files;


/*
 * Should we load this from cache
 */
@synthesize forceReload;


- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ path => \"%@\", totalFiles => \"%lu\"}", NSStringFromClass([self class]), path, [files count]];
}

@end
