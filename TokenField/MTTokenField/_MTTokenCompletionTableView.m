//
//  MTTokenCompletionTableView.m
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

#import "_MTTokenCompletionTableView.h"

@implementation _MTTokenCompletionTableView

-(void) resetWindowFrame{
    CGFloat totalHeight = MIN([self numberOfRows],10)*([self rowHeight]+[self intercellSpacing].height);
    NSRect f= [[self window] frame];
    CGFloat top =NSMaxY(f);
    CGFloat bottom = top-totalHeight;
    f = NSMakeRect(NSMinX(f), bottom, NSWidth(f), totalHeight);
    [[self window] setFrame:f display:YES];
}

-(void)reloadData{
    
    [super reloadData];
    [self resetWindowFrame];
}
@end
