//
//  RemoteFile.m
//  objective-curl
//
//  Created by nrj on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RemoteFile.h"


@implementation RemoteFile

/*
 * Filename
 */
@synthesize name;

/*
 * Filesize
 */
@synthesize size;

/*
 * Last Modified Timestamp
 */ 
@synthesize lastModified;

/*
 * Is this a directory?
 */
@synthesize isDir;

/*
 * Is this a symbolic link?
 */
@synthesize isSymLink;


- (NSString *)description
{
	return [NSString stringWithFormat:@"{RemoteFile : \"name\" => \"%@\", \"size\" => \"%d\", \"isDir\" => \"%d\", \"lastModified\" => \"%d\"}", name, size, isDir, lastModified];
}


@end
