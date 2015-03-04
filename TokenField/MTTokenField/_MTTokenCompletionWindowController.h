//
//  MTTokenCompletionWindowController.h
//  TokenField
//
//  Copyright (c) 2012-2015 Indev Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
//  persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
//  Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Cocoa/Cocoa.h>
#import "_MTTokenTextView.h"
#import "_MTTokenCompletionTableView.h"

@interface _MTTokenCompletionWindowController : NSWindowController <NSTableViewDelegate,NSTableViewDataSource,NSWindowDelegate>
{
    NSWindow * completionWindow;
    __unsafe_unretained _MTTokenTextView * textView;
    id _eventMonitor;
    NSMutableString* completionStem_;
    NSUInteger completionIndex_;
    NSArray * completionsArray_;
    _MTTokenCompletionTableView * tableView_;
    NSCharacterSet* tokenizingCharacterSet_;
    
 }
@property (retain)NSArray * completionsArray;
@property (assign)_MTTokenTextView* textView;
@property (retain)NSMutableString *completionStem;
@property (assign)NSUInteger completionIndex;
@property (retain)_MTTokenCompletionTableView* tableView;
@property (retain)NSCharacterSet* tokenizingCharacterSet;
+ (id)sharedController;
-(void)displayCompletionsForStem:(NSString*) stem forTextView:(NSTextView*)aTextView forRange:(NSRange)stemRange;
-(void)tearDownWindow;
-(BOOL)isDisplayingCompletions;

@end
