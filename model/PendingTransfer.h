//
//  FTPCommand.h
//  objective-curl
//
//  Created by nrj on 1/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <stdio.h>
#import <sys/stat.h>

@interface PendingTransfer : NSObject 
{
	NSString *localPath;
	NSString *remotePath;
	
	BOOL isEmptyDirectory;
}

@property(readwrite, copy) NSString *localPath;
@property(readwrite, copy) NSString *remotePath;
@property(readwrite, assign) BOOL isEmptyDirectory;

- (id)initWithLocalPath:(NSString *)aLocalPath remotePath:(NSString *)aRemotePath;

- (FILE *)getHandle;

- (int)getInfo:(struct stat *)info;

@end
