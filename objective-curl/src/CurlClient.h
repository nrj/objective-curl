//
//  CurlClient.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//


@class CurlUpload;

@protocol CurlClient

- (SecProtocolType)protocol;

- (int)clientType;

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (void)setVerbose:(BOOL)verbose;
- (BOOL)verbose;

- (void)setShowProgress:(BOOL)showProgress;
- (BOOL)showProgress;

- (CurlUpload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username;

- (CurlUpload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password;

- (CurlUpload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory;

- (CurlUpload *)uploadFilesAndDirectories:(NSArray *)filesAndDirectories toHost:(NSString *)hostname username:(NSString *)username password:(NSString *)password directory:(NSString *)directory port:(int)port;

- (void)upload:(CurlUpload *)record;

- (CURL *)newHandle;

@end
