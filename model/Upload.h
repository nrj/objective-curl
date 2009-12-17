//
//  Upload.h
//  objective-curl
//
//  Created by nrj on 8/25/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransferRecord.h"
#import "CurlStatus.h"


@interface Upload : NSObject <TransferRecord, NSCoding>
{
	NSString *name;
	
	NSArray  *localFiles;
	NSString *currentFile;
	
	NSString *username;
	NSString *hostname;
	NSString *directory;

	int status;	
	NSString *statusMessage;

	int progress;
	int totalFiles;
	int totalFilesUploaded;
}


@property(readwrite, copy) NSString *name;

@property(readwrite, retain) NSArray *localFiles;
@property(readwrite, copy) NSString *currentFile;

@property(readwrite, copy) NSString *username;
@property(readwrite, copy) NSString *hostname;
@property(readwrite, copy) NSString *directory;

@property(readwrite, assign) int status;
@property(readwrite, copy) NSString *statusMessage;

@property(readwrite, assign) int progress;
@property(readwrite, assign) int totalFiles;
@property(readwrite, assign) int totalFilesUploaded;


@end
