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
	NSString *name;
	NSString *currentFile;
	NSArray *localFiles;
	
	int progress;
	int totalFiles;
	int totalFilesUploaded;
	
	BOOL isUploading;
}


@property(readwrite, copy) NSString *name;
@property(readwrite, retain) NSArray *localFiles;
@property(readwrite, assign) int totalFiles;
@property(readwrite, assign) int totalFilesUploaded;
@property(readwrite, assign) int progress;
@property(readwrite, copy) NSString *currentFile;
@property(readwrite, assign) BOOL isUploading;


@end
