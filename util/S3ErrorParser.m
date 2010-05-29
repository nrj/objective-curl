//
//  S3ErrorParser.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "S3ErrorParser.h"


@implementation S3ErrorParser


+ (NSString *)parseErrorMessage:(NSString *)resp 
{
	NSError *err = nil;
	NSString *s3ErrorMessage = @"Unknown Amazon S3 Error";
	NSXMLDocument *xml = [[NSXMLDocument alloc] initWithXMLString:resp 
														  options:NSXMLDocumentTidyXML
															error:&err];
	if (!err) {
		NSXMLNode *msgNode = [[xml nodesForXPath:@"./Error/Message" error:nil] objectAtIndex:0];
		NSXMLNode *codeNode = [[xml nodesForXPath:@"./Error/Code" error:nil] objectAtIndex:0];
		
		s3ErrorMessage = [NSString stringWithFormat:@"%@: %@", [codeNode stringValue], [msgNode stringValue]];
	}
	else {
		NSLog(@"Error parsing S3 Response: %@", [err description]);
	}
	
	[xml release];
	
	return s3ErrorMessage;
}


@end
