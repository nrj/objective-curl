//
//  CurlFTP.h
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurlObject.h"

#define DEFAULT_FTP_PORT 21

@interface CurlFTP : CurlObject

- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host;
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host port:(int)port;
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host port:(int)port directory:(NSString *)directory;
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host port:(int)port directory:(NSString *)directory maxConnects:(int)maxConnects;

- (CURL *)newUploadHandle:(NSString *)url withCredentials:(NSString *)credentials;

- (void)handleFTPResponse:(int)code;

@end
