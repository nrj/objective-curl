//
//  RemoteFile.h
//  objective-curl
//
//  Created by nrj on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RemoteFile : NSObject 
{
	NSString *name;
	long size;
	long lastModified;
	BOOL isDir;	
}

@property(readwrite, copy) NSString *name;
@property(readwrite, assign) long size;
@property(readwrite, assign) long lastModified;
@property(readwrite, assign) BOOL isDir;

@end
