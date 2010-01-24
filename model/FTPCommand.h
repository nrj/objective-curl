//
//  FTPCommand.h
//  objective-curl
//
//  Created by nrj on 1/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef enum {
	FTP_COMMAND_PUT,
	FTP_COMMAND_MKDIR,
	FTP_COMMAND_LIST
} FTPCommandType;


@interface FTPCommand : NSObject {

	FTPCommandType type;
	NSString *localPath;
	NSString *remotePath;
	
}

@property(readwrite, assign) FTPCommandType type;
@property(readwrite, copy) NSString *localPath;
@property(readwrite, copy) NSString *remotePath;

- (id)initWithType:(FTPCommandType)aType localPath:(NSString *)aLocalPath remotePath:(NSString *)aRemotePath;

- (NSString *)text;

@end
