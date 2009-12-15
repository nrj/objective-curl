//
//  RemoteLocation.h
//  objective-curl
//
//  Created by nrj on 12/15/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RemoteLocation 

- (int)type;
- (void)setType:(int)aType;

- (NSString *)hostname;
- (void)setHostname:(NSString *)aHostname;

- (NSString *)port;
- (void)setPort:(NSString *)aPort;

- (NSString *)username;
- (void)setUsername:(NSString *)aUsername;

- (NSString *)password;
- (void)setPassword:(NSString *)aPassword;

- (NSString *)directory;
- (void)setDirectory:(NSString *)aDirectory;

@end

