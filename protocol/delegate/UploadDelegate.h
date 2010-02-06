//
//  UploadDelegate.h
//  objective-curl
//
//  Created by nrj on 1/3/10.
//  Copyright 2010x. All rights reserved.
//

#import "Upload.h"


@protocol UploadDelegate


/*
 * Called when the upload starts.
 */
- (void)uploadDidBegin:(Upload *)record;


/*
 * Called when the upload progress has changed (1-100%)
 */
- (void)uploadDidProgress:(Upload *)record toPercent:(NSNumber *)percent;


/*
 * Called when the upload has finished successfully.
 */
- (void)uploadDidFinish:(Upload *)record;


/*
 * Called when the upload was cancelled.
 */
- (void)uploadWasCancelled:(Upload *)record;


/*
 * Called when the upload has failed because of authentication. With this method you prompt the user to enter new
 * credentials, correct them on the upload record given to you and invoke [client retryUpload:record] to try again.
 */
- (void)uploadDidFailAuthentication:(Upload *)record message:(NSString *)message;


/*
 * Called when the upload has failed. The message will contain useful information of what went wrong. If possible  
 * correct the property values on the upload record given to you and invoke [client retryUpload:record] to try again.
 */
- (void)uploadDidFail:(Upload *)record message:(NSString *)message;


@end