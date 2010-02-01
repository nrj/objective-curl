//
//  CurlDelegate.h
//  objective-curl
//
//  Created by nrj on 2/1/10.
//  Copyright 2010. All rights reserved.
//



@protocol CurlDelegate


- (void)curlDidStartConnecting:(RemoteObject *)task;


- (void)curlDidSuccessfullyConnect:(RemoteObject *)task;


- (void)curlDidFailToConnect:(RemoteObject *)task;


- (void)curlDidFailAuthentication:(RemoteObject *)task;


@end
