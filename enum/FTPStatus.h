//
//  FTPStatus.h
//  objective-curl
//
//  Created by nrj on 12/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

typedef enum {
	
	FTP_STATUS_CONNECTED		= 220, /* Service ready for new user. */
	FTP_STATUS_NEED_PASSWORD	= 331, /* User name okay, need password. */
	FTP_STATUS_LOGIN_SUCCESS	= 230, /* User logged in, proceed. */
	FTP_STATUS_READY_FOR_DATA	= 150, /* The server is about to open a new connection on port 20 to send some data. */
	FTP_STATUS_FILE_RECEIVED	= 226, /* Requested file action successful */
	FTP_STATUS_EXITING			= 221  /* Service closing control connection. Logged out if appropriate. */
	
} FTPStatus;
