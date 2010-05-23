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
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
	NSURLResponse *resp = nil;
	NSError *err = nil;
	
	[NSURLConnection sendSynchronousRequest:req 
						  returningResponse:&resp 
									  error:&err];
	
	if (err)
	{
		NSLog(@"Error trying to get MimeType of file: %@ - %@", path, [err description]);
		return @"";
	}
	
	return [resp MIMEType];
}

@end
