//
//  RemoteFolder.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "RemoteFolder.h"


@implementation RemoteFolder


/*
 * Array of RemoteFile objects.
 */
@synthesize files;


/*
 * Should we load this from cache
 */
@synthesize forceReload;


- (NSString *)description
{
	return [NSString stringWithFormat:@"{RemoteFolder : \"path\" => \"%@\", totalFiles => \"%d\"}", path, [files count]];
}

@end
