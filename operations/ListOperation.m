//
//  ListOperation.m
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import "ListOperation.h"


@implementation ListOperation

@synthesize folder;


/*
 * Called by curl when a directory list needs to be written. Takes a pointer to an array that will be filled with RemoteFile objects.
 *
 *     See http://curl.haxx.se/libcurl/c/curl_easy_setopt.html#CURLOPTWRITEFUNCTION
 */
static size_t handleDirectoryList(void *ptr, size_t size, size_t nmemb, NSMutableArray *list)
{
	char *line = strtok((char *)ptr, "\n");
	
	do
	{
		struct ftpparse *info = malloc(sizeof(struct ftpparse));
		
		if(line) 
		{	
			if (ftpparse(info, line, strlen(line)))
			{
				char filename[info->namelen + 1];
				strncpy(filename, info->name, info->namelen);
				filename[info->namelen] = '\0';
				
				RemoteFile *file = [[RemoteFile alloc] init];	
				[file setName:[NSString stringWithCString:filename]];
				[file setIsDir:info->flagtrycwd];
				[file setIsSymLink:(info->flagtrycwd && info->flagtryretr)];
				[file setSize:info->size];
				[file setLastModified:info->mtime];
				[file setLastModified:(long)info->mtime];
				
				[list addObject:file];
			}			
		}
		
		line = strtok('\0', "\n");
		free(info);
		
	} while (line);
	
	return (size_t)(size * nmemb);
}


/*
 * Thread entry point for directory listings. Takes a pointer to the RemoteFolder.  
 */
- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
//	NSString *url = [NSString stringWithFormat:@"%@://%@:%d/%@", [folder protocolPrefix], 
//					 [folder hostname], [folder port], [folder path]];
//	
//	NSLog(@"Fetching remote directory: %@", url);
//	
//	NSMutableArray *list = [[NSMutableArray alloc] init];
//		
//	curl_easy_setopt(handle, CURLOPT_USERPWD, [[self credentials] UTF8String]);
//	curl_easy_setopt(handle, CURLOPT_WRITEFUNCTION, handleDirectoryList);
//	curl_easy_setopt(handle, CURLOPT_WRITEDATA, list);
//	curl_easy_setopt(handle, CURLOPT_UPLOAD, NO);
//	curl_easy_setopt(handle, CURLOPT_CUSTOMREQUEST, "LIST");
//	curl_easy_setopt(handle, CURLOPT_URL, [url UTF8String]);
//	
//	CURLcode result = -1;
//	
//	result = curl_easy_perform(handle);
//	
//	[self handleCurlResult:result forObject:folder];
//	
//	[list release];
//	
//	[folder setFiles:list];
//	
////	if (delegate && [delegate respondsToSelector:@selector(curl:didListRemoteDirectory:)])
////	{
////		[delegate curl:self didListRemoteDirectory:folder];
////	}
//	
	[pool drain];
	[pool release];
}

@end
