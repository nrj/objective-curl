//
//  CurlDelegate.h
//  objective-curl
//
//  Created by nrj on 12/15/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlObject.h"
#import "RemoteFolder.h"

@protocol CurlDelegate 


- (void)curl:(CurlObject *)client didListRemoteDirectory:(RemoteFolder *)dir;

/*
 * Called when a username/password is incorrect. You would likely use this to prompt a user for credentials. 
 */
- (void)curl:(CurlObject *)client authenticationDidFail:(NSString *)username forHost:(NSString *)host;


/*
 * Called when a host has an unknown or missing RSA key. You can handle this by calling one of the following:
 *
 *		    [client accepteHostKeyFingerprint:fingerprint permanently:NO];
 *          [client accepteHostKeyFingerprint:fingerprint permanently:YES];
 *          [client rejectHostKeyFingerprint:fingerprint];
 */
- (void)curl:(CurlObject *)client receivedUnknownHostKeyFingerprint:(NSString *)fingerprint;


/*
 * Called when the host key received is different from the known key. This could possible mean a man-in-the-middle attack
 * so be careful when accepting this key (see above for how how to handle it).
 */
- (void)curl:(CurlObject *)client receivedMismatchedHostKeyFingerprint:(NSString *)fingerprint;


@end