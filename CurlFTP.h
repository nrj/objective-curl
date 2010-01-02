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


extern int const DEFAULT_SFTP_PORT;

extern NSString * const FTP_PROTOCOL_PREFIX;

@interface CurlFTP : CurlObject
	
- (id)initForUpload;

int uploadProgressFunction(CurlFTP *client, double dltotal, double dlnow, double ultotal, double ulnow);

- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host;
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory;
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory port:(int)port;

- (NSArray *)createCommandsForUpload:(NSArray *)files totalFiles:(int *)totalFiles;

- (NSString *)credentials;

@end
