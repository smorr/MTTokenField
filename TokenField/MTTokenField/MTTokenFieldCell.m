//
//  MTTokenFieldCell.m
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

#import "MTTokenFieldCell.h"
#import "_MTTokenTextView.h"
#import "MTTokenField.h"
@implementation MTTokenFieldCell
@synthesize tokenizingCharacterSet= tokenizingCharacterSet_;
-(void)dealloc{
    [tokenizingCharacterSet_ release];
    [super dealloc];
}
- (void)selectWithFrame:(NSRect)aRect inView:(MTTokenField *)controlView editor:(_MTTokenTextView *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength{
    [super selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
    [textObj setTokenArray:[controlView tokenArray]];
    [textObj setSelectedRange:NSMakeRange([[textObj textStorage] length], 0)];
}

- (_MTTokenTextView *)fieldEditorForView:(NSView *)aControlView{
    static _MTTokenTextView * tokenTextView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tokenTextView = [[_MTTokenTextView alloc] init];
        [tokenTextView setFieldEditor:YES];

    });
    return tokenTextView;
}

-(NSText*)setUpFieldEditorAttributes:(NSText*)textObj{
    id result =    [super setUpFieldEditorAttributes:textObj];
    [[result textStorage] setFont:[NSFont systemFontOfSize:11]];
    return result;
}


@end
