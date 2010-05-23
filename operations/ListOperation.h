//
//  ListOperation.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import "CurlOperation.h"

@class RemoteFolder;

@interface ListOperation : CurlOperation
{
	RemoteFolder *folder;
}

@property(readwrite, retain) RemoteFolder *folder;

static size_t handleDirectoryList(void *ptr, size_t size, size_t nmemb, NSMutableArray *list);

@end
