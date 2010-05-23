//
//  FTPCommand.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import <stdio.h>
#import <sys/stat.h>


@interface FileTransfer : NSObject 
{
	NSString *localPath;
	NSString *remotePath;
	
	BOOL isEmptyDirectory;
	BOOL fileNotFound;
	
	int percentComplete;
	double totalBytes;
	double totalBytesUploaded;
}


@property(readwrite, copy) NSString *localPath;

@property(readwrite, copy) NSString *remotePath;

@property(readwrite, assign) BOOL isEmptyDirectory;

@property(readwrite, assign) BOOL fileNotFound;

@property(readwrite, assign) int percentComplete;

@property(readwrite, assign) double totalBytes;

@property(readwrite, assign) double totalBytesUploaded;


- (id)initWithLocalPath:(NSString *)aLocalPath remotePath:(NSString *)aRemotePath;

- (FILE *)getHandle;

- (int)getInfo:(struct stat *)info;

- (NSString *)getEmptyFilePath;

@end
