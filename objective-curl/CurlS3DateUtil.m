//
//  S3DateUtil.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "CurlS3DateUtil.h"


@implementation CurlS3DateUtil

+ (NSString *)dateStringForNow
{
	// Construct a date string in the format that S3 expects
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	
	[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzzz"];
	
	return [dateFormatter stringFromDate:[NSDate date]];
}

@end
