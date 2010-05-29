//
//  TestController.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>
#import <objective-curl/objective-curl.h>

@class Upload, CurlFTP, CurlSFTP, CurlSCP, CurlS3;

@interface TestController : NSObject 
{	
	CurlFTP *ftp;
	CurlSFTP *sftp;
	CurlSCP *scp;
	CurlS3 *s3;
	
	Upload *upload;
		
	IBOutlet NSWindow *sheet;
	IBOutlet NSWindow *window;
	IBOutlet NSTextField *hostnameField;
	IBOutlet NSTextField *usernameField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSTextField *remoteDirField;
	IBOutlet NSButton *connectButton;
	IBOutlet NSTextField *fileField;
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSMatrix *typeSelector;
}

@property(readwrite, retain) Upload *upload;

- (IBAction)uploadFile:(id)sender;

@end
