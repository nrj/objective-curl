//
//  CurlOperation.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//


#import <Cocoa/Cocoa.h>
#include <sys/stat.h>
#import "curl-ssh-patched.h"



@class RemoteObject;

@interface CurlOperation : NSOperation 
{
	CURL *handle;
	id delegate;
}

@property(readwrite, assign) id delegate;

- (id)initWithHandle:(CURL *)aHandle delegate:(id)aDelegate;

- (NSString *)getFailureDetailsForStatus:(CURLcode)status withObject:(RemoteObject *)object;

@end
