//
//  NSString+PathExtras.h
//  objective-curl
//
//  Created by nrj on 1/6/10.
//  Copyright 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (PathExtras)

- (NSString *)pathForFTP;
- (NSString *)appendPathForFTP:(NSString *)path;

@end
