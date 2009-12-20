//
//  TransferStatus.h
//  objective-curl
//
//  Created by nrj on 12/16/09.
//  Copyright 2009. All rights reserved.
//

typedef enum {
	TRANSFER_STATUS_CONNECTING,		/* 0 */
	TRANSFER_STATUS_AUTHENTICATING,	/* 1 */
	TRANSFER_STATUS_UPLOADING,		/* 2 */
	TRANSFER_STATUS_DOWNLOADING,	/* 3 */
	TRANSFER_STATUS_COMPLETE,		/* 4 */
	TRANSFER_STATUS_CANCELLED,		/* 5 */
	TRANSFER_STATUS_FAILED			/* 6 */
} TransferStatus;
