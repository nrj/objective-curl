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
 * Called when the upload starts the connection process.
 */
- (void)uploadIsConnecting:(Upload *)record;


/*
 * Called when the upload has started.
 */ 
- (void)uploadDidBegin:(Upload *)record;


/*
 * Called when the upload has progressed, 1-100%.
 */
- (void)uploadDidProgress:(Upload *)record toPercent:(NSNumber *)percent;


/*
 * Called when the upload process has finished successfully.
 */
- (void)uploadDidFinish:(Upload *)record;


/*
 * Called if the upload was cancelled.
 */
- (void)uploadWasCancelled:(Upload *)record;


/*
 * Called if the upload has failed because of authentication.
 */
- (void)uploadDidFailAuthentication:(Upload *)record message:(NSString *)message;


/*
 * Called when the upload has failed. The message will contain a useful description of what went wrong.
 */
- (void)uploadDidFail:(Upload *)record message:(NSString *)message;


@end