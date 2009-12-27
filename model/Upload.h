//
//  Upload.h
//  objective-curl
//
//  Created by nrj on 8/25/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransferRecord.h"


@interface Upload : NSObject <TransferRecord, NSCoding>
{
	NSString *name;
	SecProtocolType protocol;
	NSString *hostname;
	NSString *directory;
	NSString *username;	
	int port;

	int progress;
	int totalFiles;
	int totalFilesUploaded;
	NSString *currentFile;
	
	int status;	
	NSString *statusMessage;
}


@property(readwrite, copy) NSString *name;
@property(readwrite, assign) SecProtocolType protocol;
@property(readwrite, copy) NSString *hostname;
@property(readwrite, copy) NSString *directory;
@property(readwrite, copy) NSString *username;
@property(readwrite, assign) int port;

@property(readwrite, assign) int totalFiles;
@property(readwrite, assign) int totalFilesUploaded;
@property(readwrite, assign) int progress;
@property(readwrite, copy) NSString *currentFile;

@property(readwrite, assign) int status;
@property(readwrite, copy) NSString *statusMessage;

- (NSString *)protocolString;

@end
