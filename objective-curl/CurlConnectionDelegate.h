//
//  CurlConnectionDelegate.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//


@class CurlRemoteObject;


@protocol CurlConnectionDelegate

/*
 * Called when curl starts the connection process.
 */
- (void)curlIsConnecting:(CurlRemoteObject *)record;


/*
 * Called when curl successfully connects.
 */
- (void)curlDidConnect:(CurlRemoteObject *)record;


@end