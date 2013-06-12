//
//  CurlFTP.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Foundation/Foundation.h>
#import "CurlObject.h"
#import "CurlClient.h"


@class CurlUpload, CurlRemoteFolder;


@interface CurlFTP : CurlObject <CurlClient>
{
	NSMutableDictionary *directoryListCache;
}

- (NSString *)protocolPrefix;
- (int)defaultPort;

- (CurlUpload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username;
- (CurlUpload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password;
- (CurlUpload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory;
- (CurlUpload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory port:(int)port;
- (void)upload:(CurlUpload *)record;

static size_t handleDirectoryList(void *ptr, size_t size, size_t nmemb, NSMutableArray *list);

- (CurlRemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host;
- (CurlRemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload;
- (CurlRemoteFolder *)listRemoteDirectory:(NSString *)directory onHost:(NSString *)host forceReload:(BOOL)reload port:(int)port;

@end
