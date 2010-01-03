//
//  CurlFTP.h
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurlObject.h"
#import "TransferStatus.h"
#import "FTPCommand.h"
#import "Upload.h"
#import "RemoteFile.h"
#import "ftpparse.h"


extern int const DEFAULT_FTP_PORT;

extern NSString * const FTP_PROTOCOL_PREFIX;

@interface CurlFTP : CurlObject {

	NSMutableDictionary *directoryListCache;
	
}

static size_t handleDirectoryList(void *ptr, size_t size, size_t nmemb, NSMutableArray *list);

- (NSArray *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host;
- (NSArray *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload;
- (NSArray *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload port:(int)port;

- (RemoteFile *)existingFileOrDirectory:(NSString *)filename onHost:(NSString *)host atPath:(NSString *)path;
- (RemoteFile *)existingFileOrDirectory:(NSString *)filename onHost:(NSString *)host atPath:(NSString *)path port:(int)port;

- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host;
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory;
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory port:(int)port;

- (NSArray *)createCommandsForUpload:(NSArray *)files totalFiles:(int *)totalFiles;

- (NSString *)credentials;

@end
