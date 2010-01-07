//
//  CurlFTP.h
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+PathExtras.h"
#import "CurlObject.h"
#import "CurlDelegate.h"
#import "TransferStatus.h"
#import "FTPCommand.h"
#import "RemoteFile.h"
#import "RemoteFolder.h"
#import "Upload.h"
#import "ftpparse.h"


extern int const DEFAULT_FTP_PORT;

extern NSString * const FTP_PROTOCOL_PREFIX;

@interface CurlFTP : CurlObject {

	NSMutableDictionary *directoryListCache;

}

static size_t handleDirectoryList(void *ptr, size_t size, size_t nmemb, NSMutableArray *list);

- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host;
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload;
- (RemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload port:(int)port;

- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host;
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory;
- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory port:(int)port;

- (void)checkUploadForOverwrites:(NSArray *)filesAndDirectories;

- (NSArray *)createCommandsForUpload:(NSArray *)filesAndDirectories totalFiles:(int *)totalFiles;

- (NSString *)credentials;

@end
