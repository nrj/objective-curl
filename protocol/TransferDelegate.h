//
//  TransferDelegate.h
//  objective-curl
//
//  Created by nrj on 12/15/09.
//  Copyright 2009. All rights reserved.
//

#import "CurlObject.h"
#import "TransferRecord.h"


@protocol TransferDelegate 

/*
 * Called when a username/password is incorrect. You would likely use this to prompt a user for credentials. 
 */
- (void)curl:(CurlObject *)client transferFailedAuthentication:(id <TransferRecord>)aRecord;

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


// SSH


/*
 * Called when a host has an unknown or missing RSA key. You can accept this key temporarily by calling:
 *
 *		    [client addAcceptedHostKey:key];
 *
 * Or permanantly by calling:
 *
 *          [client addAcceptedHostKey:key toKnownHostsFile:YES];
 */
- (void)curl:(CurlObject *)client transfer:(id <TransferRecord>)aRecord receivedUnknownHostKey:(NSString *)fingerprint;

/*
 * Called when the host key received is different from the known key. This could possible mean a man-in-the-middle attack
 * so be careful when accepting this key (see above for how how to accept it).
 */
- (void)curl:(CurlObject *)client transfer:(id <TransferRecord>)aRecord receivedMismatchedHostKey:(NSString *)fingerprint;

@end