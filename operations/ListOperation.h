//
//  ListOperation.h
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CurlOperation.h"
#import "RemoteFolder.h"
#import "RemoteFile.h"
#import "ftpparse.h"

@interface ListOperation : CurlOperation
{
	RemoteFolder *folder;
}

@property(readwrite, retain) RemoteFolder *folder;

static size_t handleDirectoryList(void *ptr, size_t size, size_t nmemb, NSMutableArray *list);

@end
