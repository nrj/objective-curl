//
//  CurlOperation.m
//  objective-curl
//
//  Base class for all curl related operations.
//
//  Created by nrj on 1/24/10.
//  Copyright 2010. All rights reserved.
//

#import "CurlOperation.h"


@implementation CurlOperation


- (id)initWithHandle:(CURL *)aHandle
{
	if (self = [super init])
	{
		handle = aHandle;
	}
	
	return self;
}

@end
