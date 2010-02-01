//
//  CurlOperation.h
//  objective-curl
//  
//  Base class for all curl related operations.
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <curl/curl.h>
#include <sys/stat.h>

@class RemoteObject;

@interface CurlOperation : NSOperation 
{
	CURL *handle;
}

- (NSString *)getFailureDetailsForStatus:(CURLcode)status withObject:(RemoteObject *)object;

@end
