//
//  RemoteFile.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
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
