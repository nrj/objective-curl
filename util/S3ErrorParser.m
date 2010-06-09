//
//  S3ErrorParser.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "S3ErrorParser.h"
#import "S3ErrorCodes.h"
#import "TransferStatus.h"


const NSString * S3ErrorCodeKey		= @"S3ErrorCode";

const NSString * S3ErrorMessageKey	= @"S3ErrorMessage";


@implementation S3ErrorParser


+ (NSDictionary *)parseErrorDetails:(NSString *)resp
{
	NSString *s3ErrorCode	 = @"Unknown";
	NSString *s3ErrorMessage = @"Amazon S3 Error";
	NSError *err = nil;
	NSXMLDocument *xml = [[NSXMLDocument alloc] initWithXMLString:resp 
														  options:NSXMLDocumentTidyXML
															error:&err];
	
	

	if (!err) {
		NSXMLNode *msgNode, *codeNode = nil;
		
		msgNode  = [[xml nodesForXPath:@"./Error/Message" error:nil] objectAtIndex:0];
		
		codeNode = [[xml nodesForXPath:@"./Error/Code" error:nil] objectAtIndex:0];
		
		s3ErrorCode = [codeNode stringValue];
		s3ErrorMessage = [msgNode stringValue];
	}
	else {
		NSLog(@"Error parsing S3 Response: %@", [err description]);
	}
	
	[xml release];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:	s3ErrorCode,
														S3ErrorCodeKey, 
														s3ErrorMessage, 
														S3ErrorMessageKey, 
														NULL];
}


+ (int)transferStatusForErrorCode:(NSString *)code
{	
	if ([code isEqualToString:(NSString *)S3SignatureDoesNotMatch] ||
		[code isEqualToString:(NSString *)S3InvalidAccessKeyId]) {
		return TRANSFER_STATUS_LOGIN_DENIED;
	}

	return TRANSFER_STATUS_FAILED;
}


@end
