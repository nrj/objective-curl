//
//  TransferStatus.h
//  objective-curl
//
//  Created by nrj on 12/16/09.
//  Copyright 2009. All rights reserved.
//

typedef enum {
	TRANSFER_STATUS_QUEUED = 1,
	TRANSFER_STATUS_CONNECTING,
	TRANSFER_STATUS_UPLOADING,
	TRANSFER_STATUS_COMPLETE,
	TRANSFER_STATUS_CANCELLED,
	TRANSFER_STATUS_LOGIN_DENIED,
	TRANSFER_STATUS_FAILED
} TransferStatus;
