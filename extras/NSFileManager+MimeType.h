//
//  NSString+MimeType.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>


@interface NSFileManager (MimeType)


+ (NSString *)mimeTypeForFileAtPath:(NSString *)path;

@end
