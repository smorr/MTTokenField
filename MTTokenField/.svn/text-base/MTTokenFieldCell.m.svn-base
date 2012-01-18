//
//  MTTokenFieldCell.m
//  TokenField
//
//  Created by smorr on 11-11-29.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
    if (!tokenTextView){
        tokenTextView = [[_MTTokenTextView alloc] init];
        [tokenTextView setFieldEditor:YES];
    }
    return tokenTextView;
}

-(NSText*)setUpFieldEditorAttributes:(NSText*)textObj{
    id result =    [super setUpFieldEditorAttributes:textObj];
    [[result textStorage] setFont:[NSFont systemFontOfSize:11]];
    return result;
}


@end
