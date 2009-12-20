//
//  FTPResponse.h
//  objective-curl
//
//  Created by nrj on 12/18/09.
//  Copyright 2009. All rights reserved.
//

typedef enum {
	
	FTP_RESPONSE_CONNECTED		= 220, /* Service ready for new user. */
	FTP_RESPONSE_NEED_PASSWORD	= 331, /* User name okay, need password. */
	FTP_RESPONSE_LOGIN_SUCCESS	= 230, /* User logged in, proceed. */
	FTP_RESPONSE_READY_FOR_DATA	= 150, /* The server is about to open a new connection on port 20 to send some data. */
	FTP_RESPONSE_FILE_RECEIVED	= 226, /* Requested file action successful */
	FTP_RESPONSE_EXITING		= 221  /* Service closing control connection. Logged out if appropriate. */
	
} FTPResonse;
