//
//  TestController.h
//  objective-curl
//
//  Created by nrj on 12/7/09.
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objective-curl/sftp.h>


@interface TestController : NSObject 
{	
	CurlFTP *ftp;
	
	Upload *upload;
	
	RemoteFolder *folder;
	
	IBOutlet NSWindow *sheet;
	IBOutlet NSWindow *window;
	IBOutlet NSTableView *fileView;
	IBOutlet NSTextField *hostnameField;
	IBOutlet NSTextField *usernameField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSButton *connectButton;
	IBOutlet NSTextField *fileField;
	IBOutlet NSTextField *listStatusMessage;
	IBOutlet NSTextField *uploadStatusMessage;
	IBOutlet NSProgressIndicator *progressBar;
}

@property(readwrite, retain) Upload *upload;
@property(readwrite, retain) RemoteFolder *folder;

- (IBAction)listRemoteDirectory:(id)sender;
- (IBAction)uploadFile:(id)sender;

@end
