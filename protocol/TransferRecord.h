//
//  TransferRecord.h
//  objective-curl
//
//  Created by nrj on 12/15/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TransferRecord 

- (NSString *)name;
- (void)setName:(NSString *)aName;

- (NSArray *)localFiles;
- (void)setLocalFiles:(NSArray *)fileList;

- (NSString *)username;
- (void)setUsername:(NSString *)aUsername;

- (NSString *)hostname;
- (void)setHostname:(NSString *)aHostname;

- (NSString *)directory;
- (void)setDirectory:(NSString *)aDirectory;

- (NSString *)currentFile;
- (void)setCurrentFile:(NSString *)aFile;

- (int)totalFiles;
- (void)setTotalFiles:(int)numFiles;

- (int)totalFilesUploaded;
- (void)setTotalFilesUploaded:(int)numFiles;

- (NSString *)status;
- (void)setStatus:(NSString *)aStatus;

- (int)progress;
- (void)setProgress:(int)newProgress;

- (BOOL)isActiveTransfer;

@end