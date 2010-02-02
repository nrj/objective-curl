//
//  ConnectionDelegate.h
//  objective-curl
//
//  Created by nrj on 2/1/10.
//  Copyright 2010. All rights reserved.
//



@protocol ConnectionDelegate


- (void)curlDidStartConnecting:(RemoteObject *)task;


- (void)curlDidConnect:(RemoteObject *)task;


- (void)curlDidFailToConnect:(RemoteObject *)task;


@end
