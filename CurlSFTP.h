//
//  CurlSFTP.h
//  objective-curl
//
//  Created by nrj on 12/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CurlFTP.h"


extern int const DEFAULT_SFTP_PORT;

extern NSString * const DEFAULT_KNOWN_HOSTS;

extern NSString * const SFTP_PROTOCOL_PREFIX;


@interface CurlSFTP : CurlFTP <CurlClient>
{
	NSString *knownHostsFile;
}

@property(readwrite, copy) NSString *knownHostsFile;

@end
