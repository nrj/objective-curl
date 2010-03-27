//
//  Upload.h
//  objective-curl
//
//  Created by nrj on 8/25/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteObject.h"


@interface Upload : RemoteObject
{	
	NSArray *localFiles;
	NSString *currentFile;
	
	NSMutableArray *progressInfo;
	
	int progress;
	int totalFiles;
	int totalFilesUploaded;
	
	double totalBytes;
	double totalBytesUploaded;

	double bytesPerSecond;
	double secondsRemaining;
}


@property(readwrite, retain) NSArray *localFiles;
@property(readwrite, copy) NSString *currentFile;

@property(readwrite, retain) NSMutableArray *progressInfo;

@property(readwrite, assign) int progress;
@property(readwrite, assign) int totalFiles;
@property(readwrite, assign) int totalFilesUploaded;

@property(readwrite, assign) double totalBytes;
@property(readwrite, assign) double totalBytesUploaded;
@property(readwrite, assign) double bytesPerSecond;
@property(readwrite, assign) double secondsRemaining;


- (void)initProgressInfo;

- (void)updateProgressInfo;

- (BOOL)isActive;

@end
