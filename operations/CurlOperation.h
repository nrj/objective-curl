/*!
    @header CurlOperation.h
    @abstract   Abstract class used for as the base for all transfer operations.  
    @discussion Abstract class used for as the base for all transfer operations.
*/

#import <Cocoa/Cocoa.h>
#include <sys/stat.h>
#include <curl/curl.h>

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
