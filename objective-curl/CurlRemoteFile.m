//
//  CurlRemoteFile.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "CurlRemoteFile.h"


@implementation CurlRemoteFile

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
	return [NSString stringWithFormat:@"{RemoteFile : \"name\" => \"%@\", \"size\" => \"%lu\", \"isDir\" => \"%d\", \"lastModified\" => \"%lu\"}", name, size, isDir, lastModified];
}


@end
