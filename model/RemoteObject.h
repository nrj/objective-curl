//
//  RemoteObject.h
//  objective-curl
//
//  Created by nrj on 1/4/10.
//  Copyright 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RemoteObject : NSObject 
{
	SecProtocolType protocol;
	NSString *hostname;
	int port;
	int status;	
	NSString *statusMessage;
}

@property(readwrite, assign) SecProtocolType protocol;
@property(readwrite, copy) NSString *hostname;
@property(readwrite, assign) int port;
@property(readwrite, assign) int status;
@property(readwrite, copy) NSString *statusMessage;

- (NSString *)protocolString;

@end
