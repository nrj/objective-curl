//
//  S3ListOperation.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "S3ListOperation.h"
#import "S3ErrorParser.h"
#import "S3DateUtil.h"
#import "RemoteObject.h"
#import "NSString+S3.h"



@implementation S3ListOperation


@synthesize request;



static size_t handleS3BucketList(void *ptr, size_t size, size_t nmemb, void *data)
{
	size_t realsize = size * nmemb;
	
	struct ResultStruct *res = (struct ResultStruct *)data;
	
	res->buffer = ptr ? realloc(res->buffer, res->size + realsize + 1) : malloc(res->size + realsize + 1);
	
	if (res->buffer) {
		memcpy(&(res->buffer[res->size]), ptr, realsize);
		res->size += realsize;
		res->buffer[res->size] = 0;
	}
	
	return realsize;
}



static size_t handleS3BucketListProgress(S3ListOperation *operation, int connected, double dltotal, double dlnow, double ultotal, double ulnow)
{
	RemoteObject *request = [operation request];
	
	if (!connected)
	{		
		if ([request status] != TRANSFER_STATUS_CONNECTING)
		{
			// Connecting ...
			[request setConnected:NO];
			[request setStatus:TRANSFER_STATUS_CONNECTING];
			
			// Notify the delegate
			[operation performDelegateSelector:@selector(curlIsConnecting:)];
		}
	}
	else
	{
		if (![request connected])
		{
			// We have a connection.
			[request setConnected:YES];
			[request setStatus:TRANSFER_STATUS_CONNECTED];
			
			// Notify the delegate
			[operation performDelegateSelector:@selector(curlDidConnect:)];			
		}
	}	
	
	return ([request cancelled] || [request status] == TRANSFER_STATUS_FAILED);
}



- (void)setupCurl
{
	curl_easy_setopt(handle, CURLOPT_SSL_VERIFYPEER, 0);
	curl_easy_setopt(handle, CURLOPT_WRITEFUNCTION, handleS3BucketList);
	curl_easy_setopt(handle, CURLOPT_PROGRESSFUNCTION, handleS3BucketListProgress);
	curl_easy_setopt(handle, CURLOPT_PROGRESSDATA, self);
}



- (void)main
{	
	if ([self isCancelled]) return;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self setupCurl];

	NSString *url = [NSString stringWithFormat:@"%@://%@:%d/%@", 
							[request protocolPrefix], [request hostname], [request port], [request path]];
	
	struct ResultStruct resp;
	resp.buffer = NULL;
	resp.size   = 0;
	
	curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
	curl_easy_setopt(handle, CURLOPT_WRITEDATA, &resp);
	
	// Setup S3 Headers
	NSString *accessKey = [request username];
	NSString *secretKey = [request password];
	NSString *date = [S3DateUtil dateStringForNow];
	NSString *resource = [NSString stringWithFormat:@"/%@", [request path]];
			
	// Details of the request to be signed
	NSString *stringToSign = [NSString stringWithFormat:@"GET\n\n\n%@\n%@", date, resource];
		
	// Construct the S3 authorization header
	NSString *authString = [NSString stringWithFormat:@"AWS %@:%@", 
							accessKey, [stringToSign signS3PutRequestWithKey:secretKey]];
	
	struct curl_slist *headers = NULL;
	
	// Set the Request Headers
	headers = curl_slist_append(headers, "User-Agent:");
	headers = curl_slist_append(headers, "Accept:");
	headers = curl_slist_append(headers, "Expect:");
	headers = curl_slist_append(headers, [[NSString stringWithFormat:@"Date: %@", date] UTF8String]);
	headers = curl_slist_append(headers, [[NSString stringWithFormat:@"Authorization: %@", authString] UTF8String]);
	
	curl_easy_setopt(handle, CURLOPT_HTTPHEADER, headers);
	
	int result = -1;
	
	result = curl_easy_perform(handle);
	
	[self handleS3BucketListResult:result body:[NSString stringWithUTF8String:resp.buffer]];
	
	if (resp.buffer) {
		free(resp.buffer);
	}
	
	[pool drain];
}



- (void)handleS3BucketListResult:(CURLcode)result body:(NSString *)xml
{
	NSDictionary *error = [S3ErrorParser parseErrorDetails:xml];
	
	if (!error && result == CURLE_OK) {
		
		// [request setStatus:TRANSFER_STATUS_COMPLETE];
	
	}
	else {	
		
		[self handleS3BucketListFailed:result error:error];
	}
}



- (void)handleS3BucketListFailed:(CURLcode)result error:(NSDictionary *)s3error
{
	// The upload operation failed.
	int status;
	
	if (s3error) {
		
		NSString *s3code = [s3error objectForKey:S3ErrorCodeKey];
		NSString *s3message = [s3error objectForKey:S3ErrorMessageKey];
		
		[request setStatus:[S3ErrorParser transferStatusForErrorCode:s3code]];
		
		NSString *message = ([request status] == TRANSFER_STATUS_LOGIN_DENIED) ? 
								[self getFailureDetailsForStatus:CURLE_LOGIN_DENIED withObject:request] : 
								[NSString stringWithFormat:@"%@:%@", s3code, s3message]; 
		
		[request setStatusMessage:message];
	}
	else
	{
		switch (result)
		{
				// Auth Failure
			case CURLE_LOGIN_DENIED:
				status = TRANSFER_STATUS_LOGIN_DENIED;
				break;
				
				// General Failure
			default:
				status = TRANSFER_STATUS_FAILED;
				break;
		}
		
		[request setStatus:status];
		[request setStatusMessage:[self getFailureDetailsForStatus:result withObject:request]];
	
	}
	
	[self cancel];
}



- (void)performDelegateSelector:(SEL)aSelector
{
	if (delegate && [delegate respondsToSelector:aSelector])
	{
		[delegate performSelectorOnMainThread:aSelector withObject:request waitUntilDone:NO];
	}
}


@end
