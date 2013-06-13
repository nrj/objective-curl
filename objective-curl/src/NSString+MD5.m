//
//  NSString+MD5.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
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
		[values addObject:[NSString stringWithUTF8String:hexValue]];
	}
	
	return [values componentsJoinedByString:@":"];
}

+ (NSString *)formattedMD5FromBase64:(const char *)data length:(unsigned long)len
{
	BIO *b64, *bmem;
	
	char *buffer = (char *)malloc(len);
	memset(buffer, 0, len);
	
	b64 = BIO_new(BIO_f_base64());
	
	BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
	
	bmem = BIO_new_mem_buf((char *)data, (int)len);
	bmem = BIO_push(b64, bmem);
	
	BIO_read(bmem, buffer, (int)len);
	
	BIO_free_all(bmem);
	
	NSString *result = [NSString formattedMD5:buffer length:len];
	
	free(buffer);
	
	return result;
}



@end