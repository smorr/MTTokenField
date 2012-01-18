//
//  MTAppDelegate.h
//  TokenField
//
//  Created by smorr on 11-11-29.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTTokenField.h"

@interface MTAppDelegate : NSObject <NSApplicationDelegate,NSTableViewDataSource,MTTokenFieldDelegate,NSTokenFieldDelegate>
@property (retain) NSMutableArray* tokensForCompletion;
@property (assign) IBOutlet MTTokenField *myTokenField;
@property (assign) IBOutlet NSTokenField *standardTokenField;
@property (assign) IBOutlet NSTableView *tableView;
@property (assign) NSInteger option;
@property (assign) IBOutlet NSWindow *window;
-(IBAction)click:(id)sender;
@end
