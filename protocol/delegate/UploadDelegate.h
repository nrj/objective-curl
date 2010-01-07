//
//  UploadDelegate.h
//  objective-curl
//
//  Created by nrj on 1/3/10.
//  Copyright 2010x. All rights reserved.
//


#import "TransferRecord.h"
#import "TransferStatus.h"

@protocol UploadDelegate


/*
 * Called when the upload starts.
 */
- (void)uploadDidBegin:(id <TransferRecord>)record;


/*
 * Called when the upload has finished successfully.
 */
- (void)uploadDidFinish:(id <TransferRecord>)record;


/*
 * Called when the upload progress has changed (1-100%)
 */
- (void)upload:(id <TransferRecord>)record didProgress:(int)percent;


/*
 * Called when the status of the upload changes.
 */
- (void)upload:(id <TransferRecord>)record statusDidChange:(TransferStatus)status;


/*
 * Called when an upload will overwrite a remote file or directory
 * 
 *      To allow the overwrite:
 *           [[record filesToOverwrite] addObject:file];
 *
 *		To overwrite all files in this upload:
 *           [record setOverwriteAllFiles:YES];
 */
- (void)upload:(id <TransferRecord>)record willOverwriteFile:(RemoteFile *)file;


@end
