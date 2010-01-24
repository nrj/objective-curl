//
//  UploadOperation.h
//  objective-curl
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CurlOperation.h"
#import "FTPCommand.h"
#import "Upload.h"

@interface UploadOperation : CurlOperation 
{
	Upload *transfer;
}

@property(readwrite, retain) Upload *transfer;

static int handleCurlProgress(Upload *transfer, double dltotal, double dlnow, double ultotal, double ulnow);

- (NSArray *)createCommandsForUpload:(NSArray *)files totalFiles:(int *)totalFiles;

@end
