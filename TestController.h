//
//  TestController.h
//  objective-curl
//
//  Created by nrj on 12/7/09.
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ftp.h"

@interface TestController : NSObject 
{
	IBOutlet NSProgressIndicator *progress;
	
	CurlFTP *ftp;
	
	id <TransferRecord>upload;
}

@property(readwrite, retain) id <TransferRecord>upload;

- (void)runCurlTest;

@end
