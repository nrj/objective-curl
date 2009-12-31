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
	IBOutlet NSTextField *currentFileLabel;
	
	id <TransferRecord>upload;
	
	BOOL uploadEnabled;
}

@property(readwrite, retain) id <TransferRecord>upload;
@property(readwrite, assign) BOOL uploadEnabled;

- (IBAction)runFTPTest:(id)sender;
- (IBAction)runSFTPTest:(id)sender;

@end
