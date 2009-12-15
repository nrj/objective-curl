//
//  TransferRecord.h
//  objective-curl
//
//  Created by nrj on 12/15/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteLocation.h"

@protocol TransferRecord 

- (NSString *)name;
- (void)setName:(NSString *)aName;

- (NSString *)currentFile;
- (void)setCurrentFile:(NSString *)aFile;

- (int)totalFiles;
- (void)setTotalFiles:(int)numFiles;

- (int)totalFilesUploaded;
- (void)setTotalFilesUploaded:(int)numFiles;

- (NSString *)status;
- (void)setStatus:(NSString *)aStatus;

- (NSArray *)localFiles;
- (void)setLocalFiles:(NSArray *)fileList;

- (int)progress;
- (void)setProgress:(int)newProgress;

- (id)task;
- (void)setTask:(id)aTask;

- (id <RemoteLocation>)location;
- (void)setLocation:(id <RemoteLocation>)aLocation;

- (BOOL)isActiveTransfer;

@end