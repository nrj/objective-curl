//
//  RemoteFolder.h
//  objective-curl
//
//  Created by nrj on 1/4/10.
//  Copyright 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteObject.h"

@interface RemoteFolder : RemoteObject
{	
	NSArray *files;
	
	BOOL forceReload;
}

@property(readwrite, retain) NSArray *files;
@property(readwrite, assign) BOOL forceReload;

@end
