//
//  CurlDelegate.h
//  objective-curl
//
//  Created by nrj on 12/15/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlObject.h"
#import "TransferRecord.h"


@protocol CurlDelegate 


// Transfer Callbacks


/*
 * Called when a username/password is incorrect. You would likely use this to prompt a user for credentials. 
 */
- (void)curl:(CurlObject *)client authenticationDidFail:(id <TransferRecord>)aRecord;


/*
 * Called after successful authentication when the upload/download starts.
 */
- (void)curl:(CurlObject *)client transferDidBegin:(id <TransferRecord>)aRecord;


/*
 * Called when the upload/download progress has changed (1-100%)
 */
- (void)curl:(CurlObject *)client transferDidProgress:(id <TransferRecord>)aRecord;


/*
 * Called when the status of the transfer changes. See "TransferStatus.h".
 */
- (void)curl:(CurlObject *)client transferStatusDidChange:(id <TransferRecord>)aRecord;


/*
 * Called when the upload/download has finished successfully.
 */
- (void)curl:(CurlObject *)client transferDidFinish:(id <TransferRecord>)aRecord;


// SSH Callbacks


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


// Error Callbacks


/*
 * Called when curl fails to retrieve a directory listing.
 */
- (void)curl:(CurlObject *)client failedToRetrieveDirectoryListing:(NSString *)url;


@end