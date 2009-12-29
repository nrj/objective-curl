//
//  TestController.h
//  objective-curl
//
//  Created by nrj on 12/7/09.
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CurlSFTP.h"

@interface TestController : NSObject 
{
	IBOutlet NSButton *btn;
	IBOutlet NSProgressIndicator *progress;
	
	id <TransferRecord>upload;
}

@property(readwrite, retain) id <TransferRecord>upload;

- (IBAction)runTest:(id)sender;

@end
