//
//  RemoteFile.m
//  objective-curl
//
//  Created by nrj on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RemoteFile.h"


@implementation RemoteFile

@synthesize name;
@synthesize size;
@synthesize lastModified;
@synthesize isDir;

- (NSString *)description
{
	return [NSString stringWithFormat:@"{RemoteFile : \"name\" => \"%@\", \"size\" => \"%d\", \"isDir\" => \"%d\", \"lastModified\" => \"%d\"}", name, size, isDir, lastModified];
}

@end
