//
//  UploadClient.h
//  objective-curl
//
//  Created by nrj on 1/31/10.
//  Copyright 2010. All rights reserved.
//

#import "CurlClient.h"

@class Upload;

@protocol UploadClient <CurlClient>

- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username;

- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password;

- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory;

- (Upload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory port:(int)port;

- (void)retryUpload:(Upload *)upload;

@end
