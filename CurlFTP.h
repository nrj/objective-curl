//
//  CurlFTP.h
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurlObject.h"
#import "UploadClient.h"

@class Upload, RemoteFolder;

extern int const DEFAULT_FTP_PORT;

@interface CurlFTP : CurlObject <UploadClient>
{
	NSMutableDictionary *directoryListCache;
}


- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username;
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password;
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory;
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory port:(int)port;
- (void)retryUpload:(Upload *)upload;


static size_t handleDirectoryList(void *ptr, size_t size, size_t nmemb, NSMutableArray *list);

- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host;
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload;
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload port:(int)port;

@end
