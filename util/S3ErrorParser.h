//
//  S3ErrorParser.h
//  objective-curl
//
//  Created by nrj on 5/27/10.
//  Copyright 2010 cocoaism.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface S3ErrorParser : NSObject

+ (NSString *)parseErrorMessage:(NSString *)resp;

@end
