/*!
    @header NSString+PathExtras
    @abstract   Category methods for creating FTP-safe paths.
    @discussion Category methods for creating FTP-safe paths.
*/


#import <Foundation/Foundation.h>


@interface NSString (PathExtras)

- (NSString *)stringByAddingTildePrefix;
- (NSString *)stringByRemovingTildePrefix;

@end
