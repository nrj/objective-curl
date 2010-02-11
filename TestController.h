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
	CurlSFTP *sftp;
	
	Upload *upload;
		
	IBOutlet NSWindow *sheet;
	IBOutlet NSWindow *window;
	IBOutlet NSTextField *hostnameField;
	IBOutlet NSTextField *usernameField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSButton *connectButton;
	IBOutlet NSTextField *fileField;
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSMatrix *typeSelector;
}

@property(readwrite, retain) Upload *upload;

- (IBAction)uploadFile:(id)sender;

@end
