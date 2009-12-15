//
//  UploadDelegate.h
//  objective-curl
//
//  Created by nrj on 12/15/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransferRecord.h"

@protocol UploadDelegate 

- (void)uploadRequiresAuthentication:(id <TransferRecord>)aRecord;
- (void)uploadDidBegin:(id <TransferRecord>)aRecord;
- (void)uploadDidProgress:(id <TransferRecord>)aRecord toPercent:(int)aPercent;
- (void)uploadDidFinish:(id <TransferRecord>)aRecord;

@end