//
//  MTTokenCompletionWindowController.m
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

#import "_MTTokenCompletionWindowController.h"
#import "_MTTokenCompletionWindow.h"
#import "_MTTokenCompletionTableView.h"
#import "_MTTokenTextAttachment.h"
#import "_MTTokenTextView.h"
#import "KeyCodes.h"
static _MTTokenCompletionWindowController* sharedController = nil;

@implementation _MTTokenCompletionWindowController
@synthesize textView;
@synthesize completionStem =completionStem_;
@synthesize completionIndex= completionIndex_;
@synthesize completionsArray= completionsArray_;
@synthesize tableView=tableView_;
@synthesize tokenizingCharacterSet= tokenizingCharacterSet_;

+ (id)sharedController{
    
    
	if (!sharedController){
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            sharedController = [[_MTTokenCompletionWindowController alloc] init];
        });  
    }
	return sharedController;
}


-(oneway void)release{
}
-(id)retain{
    return self;   
}
-(id)copy{
    return self;
}
-(id)autorelease{
    return self;
}


- (void) setupWindow{
	NSRect scrollFrame = NSMakeRect(0, 0, 200, 100);
    NSRect tableFrame = NSZeroRect;    
    tableFrame.size = NSMakeSize(0,0);
    
    completionWindow = [[NSWindow alloc] initWithContentRect:scrollFrame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[completionWindow setWindowController:self];
	[self setWindow:completionWindow];
    [completionWindow setAlphaValue:.85];
    [completionWindow setHasShadow:YES];
    [completionWindow setOneShot:YES];
    [completionWindow setReleasedWhenClosed:NO];
    [completionWindow setDelegate:self];
    
    //[completionWindow setParentWindow:[self.textView window]];
   
    
    _MTTokenCompletionTableView *tableView = [[_MTTokenCompletionTableView alloc] initWithFrame:scrollFrame];
    self.tableView = tableView;
    [tableView setAutoresizingMask:NSViewWidthSizable];
    
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"completions"];
    [column setWidth:scrollFrame.size.width];
    [column setEditable:NO];
    [tableView addTableColumn:column];
    [column release];
    
    
    [tableView setGridStyleMask:NSTableViewGridNone ];
    [tableView setCornerView:nil];
    [tableView setHeaderView:nil];
    [tableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    
    [tableView setDelegate:self];
    [tableView setDataSource:(id)self];
    [tableView setAction:@selector(tableViewClicked:)];
    [tableView setTarget:self];
    [tableView setDoubleAction:@selector(tableAction:)];
     [tableView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:scrollFrame];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [scrollView setDocumentView:tableView];
	[scrollView setAutohidesScrollers:YES];
   
    [completionWindow setContentView:scrollView];
    [completionWindow setLevel:NSPopUpMenuWindowLevel];
     [tableView release];
    [scrollView release];
    

   }

-(void)insertCompletion{
    NSRange r = [self.textView selectedRange];
    [self.textView setSelectedRange:NSMakeRange(r.location+r.length, 0)];
    [self tearDownWindow];
}

-(void)chooseCompletion:(NSString*)completion forTextView:(_MTTokenTextView*)aTextView{
    
    
    NSRange replacementRange = [aTextView rangeForCompletion];
    //NSMakeRange(self.completionIndex, [aTextView selectedRange].location-self.completionIndex+ [aTextView selectedRange].length);
    [aTextView insertTokenForText:completion replacementRange:replacementRange]; 
 
}
-(void)displayCompletion:(NSString*)completion inTextView:(_MTTokenTextView*)aTextView{
    
    // method will display the completion in the textView , replacing currently displayed completion and adjust the selection
    // select the completed part of the completion.
    
    NSRange replacementRange = aTextView.rangeForCompletion;
    
   // NSMakeRange(self.completionIndex, [aTextView selectedRange].location-self.completionIndex+ [aTextView selectedRange].length);
    
    NSAttributedString * completionAttrString = [[NSAttributedString alloc] initWithString:completion attributes:[aTextView typingAttributes]];
    [[aTextView textStorage] replaceCharactersInRange:replacementRange withAttributedString:completionAttrString];
    [completionAttrString release];
    if (!self.completionStem){
        return;
    }
     NSRange stemRangeInCompletion= [completion rangeOfString:self.completionStem options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
    if (stemRangeInCompletion.location !=NSNotFound){
        NSUInteger selectionStart = self.completionIndex+stemRangeInCompletion.location+[self.completionStem length];
        NSUInteger selectionLength = [completion length] -stemRangeInCompletion.location-[self.completionStem length];
        NSRange newselection = NSMakeRange(selectionStart,selectionLength);
        [aTextView setSelectedRange:newselection];
    }
    __unused NSPoint windowPoint= [aTextView convertPoint:[aTextView frame].origin toView:nil];
    
    
    //NSPoint screenPoint = [[aTextView window] convertBaseToScreen:windowPoint];
    NSPoint screenPoint = NSMakePoint(0,0);
    NSRange actualRange;
    NSRange glyphRange = [[aTextView layoutManager] glyphRangeForCharacterRange:NSMakeRange(self.completionIndex,[completion length]) actualCharacterRange:&actualRange];
    NSRect r = [[aTextView layoutManager] boundingRectForGlyphRange:glyphRange inTextContainer:[aTextView textContainer]];
    if (![completionWindow isVisible]){
        NSPoint windowOrigin = NSMakePoint(screenPoint.x+r.origin.x-2,screenPoint.y-NSHeight([aTextView frame])-NSHeight([completionWindow frame])+2);
        [completionWindow setFrameOrigin:windowOrigin];
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        [[self.textView window] addChildWindow:completionWindow ordered:NSWindowAbove];
      }
}
-(void)displayCompletionsForStem:(NSString*) stem forTextView:(_MTTokenTextView*)aTextView forRange:(NSRange)stemRange{
    self.completionIndex = stemRange.location;
    self.completionStem = [[stem mutableCopy] autorelease];
    self.textView = aTextView;
    self.completionsArray = [textView getCompletionsForStem:self.completionStem]; 
    if ([self.completionsArray count]){
        
        if (completionWindow){
            [self.tableView reloadData];
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
            NSString *insertionText =  [self.completionsArray count]?[self.completionsArray objectAtIndex:0]:self.completionStem;
            
            [self displayCompletion:insertionText inTextView:textView];
            
        }
        else{
           [self setupWindow];
           [self.tableView reloadData];
       
            NSRect rect = [aTextView firstRectForCharacterRange:[aTextView rangeForCompletion] actualRange:nil];
            rect.origin.y -=5;
            __block CGFloat screenMaxX = 0.0;
            [[NSScreen screens] enumerateObjectsUsingBlock:^(NSScreen* aScreen, NSUInteger idx, BOOL *stop) {
                if (NSPointInRect(rect.origin,[aScreen visibleFrame])){
                    *stop = YES;
                    screenMaxX = NSMaxX([aScreen visibleFrame]);
                }
            }];
            
            rect.origin.x = MIN(rect.origin.x,screenMaxX-NSWidth([completionWindow frame]));
            [completionWindow setFrameTopLeftPoint:rect.origin];
            
            [completionWindow orderFrontRegardless];
            [[self.textView window] addChildWindow:completionWindow ordered:NSWindowAbove];

            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
            NSString *insertionText =  [self.completionsArray count]?[self.completionsArray objectAtIndex:0]:self.completionStem;
         
            [self displayCompletion:insertionText inTextView:textView];

        
            // set up an event monitor to close the completion window
            __block id blockself = self;
            
            _eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask|NSLeftMouseDownMask|NSRightMouseDownMask
                                                                  handler:^NSEvent*(NSEvent *theEvent) {
                
                if ([theEvent type]==NSKeyDown){
                    if ([theEvent modifierFlags] & NSCommandKeyMask){
                        [blockself tearDownWindow];
                        return theEvent;
                    }
                    
                    NSUInteger keyCode = [theEvent keyCode];
                    switch (keyCode) {
                        case KEY_ESCAPE:{
                            [self tearDownWindow];
                            [self.textView abandonCompletion];
                            return nil;
                            break;
                        }
                        case KEY_BACKSPACE:
                        case KEY_DELETE:{
                            if ([self.textView hasMarkedText]){
                                [self.textView unmarkText];
                                // return nil;
                            }
                            break;
                        }
                        case KEY_TAB:{
                            NSInteger selectedRow = [self.tableView selectedRow];
                            NSAssert(selectedRow >= 0 && selectedRow < [self.completionsArray count], @"Invalid Selected Row");
                            [self chooseCompletion:[self.completionsArray objectAtIndex:selectedRow] forTextView:self.textView];
                            [self tearDownWindow];
                            [[self.textView window] sendEvent:theEvent];
                            return nil;
                            break;
                        }
                        case KEY_RETURN:
                        case KEY_ENTER:
                        //case KEY_RIGHTARROW:
                        {
                            NSInteger selectedRow = [self.tableView selectedRow];
                            NSAssert(selectedRow >= 0 && selectedRow < [self.completionsArray count], @"Invalid Selected Row");
                            [self chooseCompletion:[self.completionsArray objectAtIndex:selectedRow] forTextView:self.textView];
                            [self tearDownWindow];
                            
                            return nil;
                            break;
                        }
                        case KEY_DOWNARROW:{
                            NSInteger selectedRow = [self.tableView selectedRow];
                            if (selectedRow<[self.tableView numberOfRows]-1){
                                [self.tableView selectRowIndexes:[NSIndexSet  indexSetWithIndex:selectedRow+1]byExtendingSelection:NO];
                            }
                            return nil;
                        }
                        case KEY_UPARROW:{
                            NSInteger selectedRow = [self.tableView selectedRow];
                            if (selectedRow>0){
                                [self.tableView selectRowIndexes:[NSIndexSet  indexSetWithIndex:selectedRow-1]byExtendingSelection:NO];
                            }
                            return nil;
                        }
                    }
                   
                    if ([[theEvent characters] length] && [self.tokenizingCharacterSet characterIsMember:[[theEvent characters] characterAtIndex:0]]){
                        NSInteger selectedRow = [self.tableView selectedRow];
                        NSAssert(selectedRow >= 0 && selectedRow < [self.completionsArray count], @"Invalid Selected Row");
                        [self chooseCompletion:[self.completionsArray objectAtIndex:selectedRow] forTextView:self.textView];
                        [self tearDownWindow];

                        return nil;
                    }
                    
                    [[textView inputContext] handleEvent:theEvent];
                    //[self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
                      return nil;
                  }
                if ([theEvent window]==completionWindow){
                    return theEvent;   
                }
                else{
                    [blockself tearDownWindow];
                    return theEvent;
                }
            }];
        }
    }
    else{
        if (completionWindow){
            [self tearDownWindow];
        }
        
    }
    
    
}

- (void)noResponderFor:(SEL)eventSelector{
    
}

-(void)tearDownWindow{
    
    if (_eventMonitor){
        [NSEvent removeMonitor:_eventMonitor];
        _eventMonitor= nil;
    }
    [[self.textView window] removeChildWindow:completionWindow];
    [completionWindow orderOut:NO];
    [completionWindow release];
    self.completionStem = nil;
    completionWindow = nil;
}


-(BOOL)isDisplayingCompletions{
    return [completionWindow isVisible];   
}

-(void)insertText:(id)aString{
    [self.completionStem appendString:aString];
    
    self.completionsArray = [textView getCompletionsForStem:self.completionStem]; 
    if ([self.completionsArray count]){
        [self displayCompletion:[self.completionsArray objectAtIndex:0] inTextView:textView];
        [self.tableView  reloadData];
    }
    else{
        [self displayCompletion:self.completionStem inTextView:textView];
        [self tearDownWindow];
    }
    return;

}


-(void)doCommandBySelector:(SEL)aSelector{
    if (aSelector == @selector(cancelOperation:)){
        NSRange r = [self.textView selectedRange];
        r.length = r.location+r.length-self.completionIndex;
        r.location = self.completionIndex;
        [self.textView replaceCharactersInRange:r withString:self.completionStem];
        [self tearDownWindow];
        return;
    }
    if (aSelector == @selector(moveDown:)|| aSelector == @selector(moveDownAndModifySelection:)){
        NSInteger proposedRow  = [self.tableView selectedRow]+1;
        if (proposedRow < [self.tableView numberOfRows] && proposedRow>=0){
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:proposedRow] byExtendingSelection:NO];   
        }
    }
    else if (aSelector == @selector(moveUp:)|| aSelector == @selector(moveUpAndModifySelection:)){
        NSInteger proposedRow  = [self.tableView selectedRow]-1;
        if (proposedRow>=0 && proposedRow < [self.tableView numberOfRows]){
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:proposedRow] byExtendingSelection:NO];   
             
        }
    }
    else if (aSelector == @selector(moveRight:)){
        NSInteger selectedRow = [self.tableView selectedRow];
        NSAssert(selectedRow >= 0 && selectedRow < [self.completionsArray count], @"Invalid Selected Row");
        [self chooseCompletion:[self.completionsArray objectAtIndex:selectedRow] forTextView:self.textView];
        [self tearDownWindow];   
    }
    else if (aSelector == @selector(deleteBackward:)){
        if ([self.completionStem length]){
            [self.completionStem replaceCharactersInRange:NSMakeRange([self.completionStem length]-1, 1) withString:@""];
            NSInteger selectedRow = [self.tableView selectedRow];
            //NSAssert(selectedRow >= 0 && selectedRow < [self.completionsArray count], @"Invalid Selected Row");
            if (selectedRow >= 0 && selectedRow < [self.completionsArray count] &&[self.completionStem length]){
                [self displayCompletion:[self.completionsArray objectAtIndex:selectedRow] inTextView:self.textView];
                self.completionsArray = [textView getCompletionsForStem:self.completionStem]; 
                [self.tableView  reloadData];
            }
            else{
                NSRange replacementRange = NSMakeRange(self.completionIndex, [self.textView selectedRange].location-self.completionIndex+ [self.textView selectedRange].length);
                [self.textView insertText:@"" replacementRange:replacementRange andBeginCompletion:NO];
                [self tearDownWindow];
            }
        }

    }
    else{
       [self tearDownWindow];
        [textView doCommandBySelector:aSelector];
   }
    
    
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[self completionsArray] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSString * stringToDisplay = [self.completionsArray objectAtIndex:row];
    return stringToDisplay;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if ([completionWindow isVisible]){
        NSInteger selectedRow = [self.tableView selectedRow];
        if (selectedRow >= 0 && selectedRow < [self.completionsArray count])//, @"Invalid Selected Row");
            [self displayCompletion:[self.completionsArray objectAtIndex:selectedRow] inTextView:self.textView];
        else{
            [self tearDownWindow];
        }
    }
}
- (void)tableViewClicked:(id)sender
{
    NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow >= 0 && selectedRow < [self.completionsArray count]){//NSAssert(selectedRow >= 0 && selectedRow < [self.completionsArray count], @"Invalid Selected Row");
        [self chooseCompletion:[self.completionsArray objectAtIndex:selectedRow] forTextView:self.textView];
     }
    [self tearDownWindow];
   
}
- (void)tableAction:(id)sender{
    
}
@end
