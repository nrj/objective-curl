//
//  RemoteFolder.m
//  objective-curl
//
//  Created by nrj on 1/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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
