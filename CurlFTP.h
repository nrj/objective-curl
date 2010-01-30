//
//  CurlFTP.h
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurlObject.h"
#import "RemoteFolder.h"
#import "RemoteFile.h"
#import "Upload.h"
#import "NSString+PathExtras.h"
#import "FTPUploadOperation.h"
#import "ListOperation.h"
#import "UploadDelegate.h"


extern int const DEFAULT_FTP_PORT;

@interface CurlFTP : CurlObject
{
	NSMutableDictionary *directoryListCache;
}

static size_t handleDirectoryList(void *ptr, size_t size, size_t nmemb, NSMutableArray *list);

- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host;
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload;
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload port:(int)port;

- (void)retryListRemoteDirectory:(RemoteFolder *)folder;

- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host;
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory;
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory port:(int)port;

- (void)retryRecursiveUpload:(Upload *)upload;

- (NSString *)credentials;

@end
