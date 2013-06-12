//
//  UploadDelegate.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//


@class CurlUpload;


@protocol CurlUploadDelegate


/*
 * Called when the upload has started.
 */ 
- (void)uploadDidBegin:(CurlUpload *)record;


/*
 * Called when the upload has progressed, 1-100%.
 */
- (void)uploadDidProgress:(CurlUpload *)record toPercent:(NSNumber *)percent;


/*
 * Called when the upload process has finished successfully.
 */
- (void)uploadDidFinish:(CurlUpload *)record;


/*
 * Called if the upload was cancelled.
 */
- (void)uploadWasCancelled:(CurlUpload *)record;


/*
 * Called when the upload has failed. The message will contain a useful description of what went wrong.
 */
- (void)uploadDidFail:(CurlUpload *)record message:(NSString *)message;


/*
 * Implement this method to determine how a UNKNOWN host key fingerprint should be handled.
 * Return an integer indicating how to proceed.
 *
 *     0 = OK. Also add to known_hosts file
 *     1 = OK.
 *     2 = REJECT.
 *     3 = DEFER. Do not proceed, but leave the connection intact. This is the default if no delegate implementation exists.
 */
- (int)acceptUnknownHostFingerprint:(NSString *)fingerprint forUpload:(CurlUpload *)record;


/*
 * Implement this method to determine how a MISMATCHED host key fingerprint should be handled.
 * See above for possible return values.
 */
- (int)acceptMismatchedHostFingerprint:(NSString *)fingerprint forUpload:(CurlUpload *)record;


@end