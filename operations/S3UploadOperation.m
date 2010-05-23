//
//  S3UploadOperation.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "S3UploadOperation.h"
#import "Upload.h"
#import "FileTransfer.h"
#import "NSString+S3.h"
#import "NSString+PathExtras.h"
#import "NSFileManager+MimeType.h"

@implementation S3UploadOperation


- (void)setFileSpecificOptions:(FileTransfer *)file
{	
	// These act the same as username and password
	NSString *accessKey = [upload username];
	NSString *secretKey = [upload password];

	// Construct the date Amazon date format 
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzzz"];
	NSString *date = [dateFormatter stringFromDate:[NSDate date]];
	
	// FIX THIS
	NSString *resource = [NSString stringWithFormat:@"/%@", [[file remotePath] stringByRemovingTildePrefix]];
	
	// Get the content type of the file we're uploading
	NSString *contentType = [NSFileManager mimeTypeForFileAtPath:[file localPath]];

	// Details of the request to be signed
	NSString *stringToSign = [NSString stringWithFormat:@"PUT\n\n%@\n%@\n%@", contentType, date, resource];
	
	// Construct the S3 authorization header
	NSString *authString = [NSString stringWithFormat:@"AWS %@:%@", 
								accessKey, [stringToSign signS3PutRequestWithKey:secretKey]];
	
	struct curl_slist *headers = NULL;
	
	// Set the Request Headers
	headers = curl_slist_append (headers, "User-Agent:");
	headers = curl_slist_append (headers, "Accept:");
	headers = curl_slist_append (headers, "Expect:");
	headers = curl_slist_append (headers, [[NSString stringWithFormat:@"Content-Type: %@", contentType] UTF8String]);
	headers = curl_slist_append (headers, [[NSString stringWithFormat:@"Date: %@", date] UTF8String]);
	headers = curl_slist_append (headers, [[NSString stringWithFormat:@"Authorization: %@", authString] UTF8String]);

	curl_easy_setopt(handle, CURLOPT_HTTPHEADER, headers);
	curl_easy_setopt(handle, CURLOPT_PUT, 1L);

	// FIX THIS
	curl_easy_setopt(handle, CURLOPT_SSL_VERIFYPEER, 0);
}


- (void)setAuthOptions{ }


@end
