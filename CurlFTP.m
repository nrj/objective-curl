//
//  CurlFTP.m
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlFTP.h"


@implementation CurlFTP

- (void)uploadFile:(NSString *)filePath toLocation:(NSString *)hostname withCredentials:(NSString *)credentials
{
	CURLcode result;
	FILE *fh;
	struct stat file_info;
	curl_off_t fsize;
	
	if(stat([filePath UTF8String], &file_info)) {
		printf("Couldnt open '%s': %s\n", [filePath UTF8String], strerror(errno));
		return;
	}
	
	fsize = (curl_off_t)file_info.st_size;
	
	fh = fopen([filePath UTF8String], "rb");
			
	curl_easy_setopt(handle, CURLOPT_UPLOAD, 1L);
	curl_easy_setopt(handle, CURLOPT_URL, [hostname UTF8String]);
	curl_easy_setopt(handle, CURLOPT_USERPWD, [credentials UTF8String]);
	curl_easy_setopt(handle, CURLOPT_READDATA, fh);
	curl_easy_setopt(handle, CURLOPT_INFILESIZE_LARGE, (curl_off_t)fsize);		
		
	result = curl_easy_perform(handle);
		
	curl_easy_cleanup(fh);
	
	fclose(fh);
}

@end
