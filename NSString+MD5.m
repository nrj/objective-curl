//
//  NSString+MD5.m
//  objective-curl
//
//  Created by nrj on 12/30/09.
//  Copyright 2009. All rights reserved.
//

#import "NSString+MD5.h"


@implementation NSString (MD5)

+ (NSString *)formattedMD5:(const char *)data length:(unsigned long)len
{
	unsigned char *digest = MD5((unsigned const char *)data, len, NULL);
	NSMutableArray *values = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < strlen((char *)digest); i++)
	{
		char hexValue[4];
		sprintf(hexValue, "%02X", digest[i]);
		[values addObject:[NSString stringWithCString:hexValue length:strlen(hexValue)]];
	}
	
	return [values componentsJoinedByString:@":"];
}

@end