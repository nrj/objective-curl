//
//  CurlStatus.h
//  objective-curl
//
//  Created by nrj on 12/16/09.
//  Copyright 2009. All rights reserved.
//

typedef enum {
	CURL_STATUS_CONNECTING = 0,
	CURL_STATUS_AUTHENTICATING = 1,
	CURL_STATUS_UPLOADING = 2,
	CURL_STATUS_UPLOAD_FINISHED = 3,
	CURL_STATUS_UPLOAD_CANCELLED = 4
} CurlStatus;
