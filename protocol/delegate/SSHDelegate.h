//
//  SSHDelegate.h
//  objective-curl
//
//  Created by nrj on 1/3/10.
//  Copyright 2010x. All rights reserved.
//


@protocol SSHDelegate


/*
 * Implement this method to determine how a UNKNOWN host key fingerprint should be handled.
 * Return an integer indicating how to proceed.
 *
 *     0 = OK. Also add to known_hosts file
 *     1 = OK.
 *     2 = REJECT.
 *     3 = DEFER. Do not proceed, but leave the connection intact. This is the default if no delegate implementation exists.
 */
- (int)acceptUnknownFingerprint:(NSString *)fingerprint forHost:(NSString *)hostname;


/*
 * Implement this method to determine how a MISMATCHED host key fingerprint should be handled.
 * Return an integer indicating how to proceed.
 *
 *     0 = OK. Also add to known_hosts file
 *     1 = OK. This is the default if no delegate implementation exists.
 *     2 = REJECT.
 *     3 = DEFER. Do not proceed, but leave the connection intact. This is the default if no delegate implementation exists.
 */
- (int)acceptMismatchedFingerprint:(NSString *)fingerprint forHost:(NSString *)hostname;


@end