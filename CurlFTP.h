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
	
- (id)initForUpload;

int uploadProgressFunction(CurlFTP *client, double dltotal, double dlnow, double ultotal, double ulnow);

- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host;
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory;
- (id <TransferRecord>)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)host directory:(NSString *)directory port:(int)port;

- (NSDictionary *)enumerateFilesForUpload:(NSArray *)files withPrefix:(NSString *)directory;

- (NSString *)credentials;

@end
