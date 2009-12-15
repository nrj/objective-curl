//
//  TestController.h
//  objective-curl
//
//  Created by nrj on 12/7/09.
//  Copyright 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TestController : NSObject 
{
	IBOutlet NSButton *btn;
}

- (IBAction)runTest:(id)sender;

@end
