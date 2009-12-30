//
//  CurlSFTP.h
//  objective-curl
//
//  Created by nrj on 12/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CurlFTP.h"
#import "TransferStatus.h"


#define DEFAULT_SFTP_PORT 22

@interface CurlSFTP : CurlFTP {

}

size_t sftpHeaderFunction(void *ptr, size_t size, size_t nmemb, void *client);

@end
