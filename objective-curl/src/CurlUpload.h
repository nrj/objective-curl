//
//  Upload.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Foundation/Foundation.h>
#import "CurlRemoteObject.h"

@class CurlFileTransfer;


@interface CurlUpload : CurlRemoteObject
{	
	NSArray *localFiles;
	
	NSArray *transfers;
	
	CurlFileTransfer *currentTransfer;
	
	NSInteger progress;
	
	NSInteger totalFiles;
	
    NSInteger totalFilesUploaded;
	
	double totalBytes;
	
	double totalBytesUploaded;
	
	double lastBytesUploaded;
	
	double bytesPerSecond;
	
	double secondsRemaining;
}


@property(readwrite, retain) NSArray *localFiles;

@property(readwrite, retain) NSArray *transfers;

@property(readwrite, assign) CurlFileTransfer *currentTransfer;

@property(readwrite, assign) NSInteger progress;

@property(readwrite, assign) NSInteger totalFiles;

@property(readwrite, assign) NSInteger totalFilesUploaded;

@property(readwrite, assign) double totalBytes;

@property(readwrite, assign) double totalBytesUploaded;

@property(readwrite, assign) double lastBytesUploaded;

@property(readwrite, assign) double bytesPerSecond;

@property(readwrite, assign) double secondsRemaining;


- (BOOL)isActive;


@end
