//
//  NSFileManager+MimeType.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "NSFileManager+MimeType.h"


@implementation NSFileManager (MimeType)

+ (NSString *)mimeTypeForFileAtPath:(NSString *)path
{
	BOOL isDir = NO;
	NSFileManager *mgr = [[NSFileManager alloc] init];
	NSString *mimeType = @"";
	
	if ([mgr fileExistsAtPath:path isDirectory:&isDir] && isDir)
	{
		mimeType = @"application/x-directory";
	}
	else
	{
		NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
		NSURLResponse *resp = nil;
		NSError *err = nil;
		
		[NSURLConnection sendSynchronousRequest:req 
								returningResponse:&resp 
											error:&err];
		if (!err)
		{
			mimeType = [resp MIMEType];
		}
		else
		{
			NSLog(@"Error trying to get MimeType of file: %@ - %@", path, [err description]);
		}
	}
	
	[mgr release];
		
	return mimeType;
}

@end
