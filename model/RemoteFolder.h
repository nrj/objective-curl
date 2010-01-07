//
//  RemoteFolder.h
//  objective-curl
//
//  Created by nrj on 1/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteObject.h"

@interface RemoteFolder : RemoteObject
{	
	NSString *path;
	NSArray *files;
	
	BOOL forceReload;
}

@property(readwrite, copy) NSString *path;
@property(readwrite, retain) NSArray *files;
@property(readwrite, assign) BOOL forceReload;

@end
