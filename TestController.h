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
	CurlSFTP *sftp;
	
	IBOutlet NSWindow *sheet;
	IBOutlet NSWindow *window;

	IBOutlet NSTableView *fileView;
	IBOutlet NSTextField *hostnameField;
	IBOutlet NSTextField *usernameField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSButton *connectButton;
	IBOutlet NSTextField *statusMessage;
	
	RemoteFolder *folder;
}

@property(readwrite, retain) RemoteFolder *folder;

- (IBAction)listRemoteDirectory:(id)sender;

- (void)initCurlObject:(CurlObject *)curl;

@end
