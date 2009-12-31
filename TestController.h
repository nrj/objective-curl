//
//  TestController.h
//  objective-curl
//
//  Created by nrj on 12/7/09.
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CurlSFTP.h"
#import "CurlFTP.h"

@interface TestController : NSObject 
{
	IBOutlet NSProgressIndicator *progress;
	
	IBOutlet NSTextField *versionLabel;	
	IBOutlet NSTextField *filepathField;
	IBOutlet NSTextField *hostnameField;
	IBOutlet NSTextField *usernameField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSTextField *statusLabel;
	
	id <TransferRecord>upload;
}

@property(readwrite, retain) id <TransferRecord>upload;

- (IBAction)runFTPTest:(id)sender;
- (IBAction)runSFTPTest:(id)sender;

@end
