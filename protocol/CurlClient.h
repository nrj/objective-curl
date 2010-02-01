//
//  CurlClient.h
//  objective-curl
//
//  Created by nrj on 1/31/10.
//  Copyright 2010. All rights reserved.
//



@protocol CurlClient

/*
 * Generate's and return a new curl_easy_handle with protocol specific options set.
 */
- (CURL *)newHandle;

/*
 * 
 */
- (void)setDelegate:(id)delegate;
- (id)delegate;

@end
