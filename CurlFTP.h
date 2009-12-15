//
//  CurlFTP.h
//  objective-curl
//
//  Created by nrj on 12/14/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurlObject.h"

@interface CurlFTP : CurlObject {

}

- (void)uploadFile:(NSString *)filePath toLocation:(NSString *)hostname withCredentials:(NSString *)credentials;

@end
