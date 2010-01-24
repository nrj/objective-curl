//
//  UploadDelegate.h
//  objective-curl
//
//  Created by nrj on 1/3/10.
//  Copyright 2010x. All rights reserved.
//

#import "Upload.h"
#import "TransferStatus.h"

@protocol UploadDelegate


/*
 * Called when the upload starts.
 */
- (void)uploadDidBegin:(Upload *)record;


/*
 * Called when the upload has finished successfully.
 */
- (void)uploadDidFinish:(Upload *)record;


/*
 * Called when the upload progress has changed (1-100%)
 */
- (void)upload:(Upload *)record didProgress:(int)percent;


/*
 * Called when the status of the upload changes.
 */
- (void)upload:(Upload *)record statusDidChange:(TransferStatus)status;


@end