//
//  RemoteObject.h
//  objective-curl
//
//  Created by nrj on 1/4/10.
//  Copyright 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransferStatus.h"


@interface RemoteObject : NSObject
{
	SecProtocolType protocol;
	NSString *hostname;
	NSString *username;
	NSString *password;
	NSString *path;
	int port;
	TransferStatus status;
	BOOL connected;
	BOOL cancelled;
}

@property(readwrite, assign) SecProtocolType protocol;
@property(readwrite, copy) NSString *hostname;
@property(readwrite, copy) NSString *username;
@property(readwrite, copy) NSString *password;
@property(readwrite, copy) NSString *path;
@property(readwrite, assign) int port;
@property(readwrite, assign) TransferStatus status;
@property(readwrite, assign) BOOL connected;
@property(readwrite, assign) BOOL cancelled;

- (NSString *)protocolString;

- (BOOL)hasAuthUsername;

- (BOOL)hasAuthPassword;

@end
