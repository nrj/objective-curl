//
//  TransferStatus.h
//  objective-curl
//
//  Created by nrj on 12/16/09.
//  Copyright 2009. All rights reserved.
//

typedef enum {
	TRANSFER_STATUS_QUEUED = 1,
	TRANSFER_STATUS_UPLOADING,		/* 2 */
	TRANSFER_STATUS_COMPLETE,		/* 3 */
	TRANSFER_STATUS_CANCELLED,		/* 4 */
	TRANSFER_STATUS_FAILED			/* 5 */
} TransferStatus;
