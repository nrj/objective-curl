/*!
    @header NSString+PathExtras
    @abstract   Category methods for creating FTP-safe paths.
    @discussion Category methods for creating FTP-safe paths.
*/


#import <Foundation/Foundation.h>


@interface NSString (PathExtras)

- (NSString *)stringByAppendingPathPreservingAbsolutePaths:(NSString *)str;
- (NSString *)stringByAddingTildePrefix;
- (NSString *)stringByRemovingTildePrefix;

@end
