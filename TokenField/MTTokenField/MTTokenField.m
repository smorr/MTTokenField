//
//  MTTokenField.m
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

#import "MTTokenField.h"
#import "MTTokenFieldCell.h"
#import "_MTTokenTextAttachment.h"
#import "_MTTokenTextView.h"
#import "MTTokenField+PrivateMethods.h"
#import "MTTokenFieldDelegate.h"
#import "NSAttributedString+MTTokenField.h"
@implementation MTTokenField
@dynamic tokenArray;
@synthesize tokenizingCharacterSet= tokenizingCharacterSet_;


-(void)dealloc{
    [tokenArray_ release];
    [tokenizingCharacterSet_ release];
    [super dealloc];
}


-(NSArray*)tokenArray{
    return [[tokenArray_ retain] autorelease];
}

-(void)setTokenArray:(NSArray*)tokenArray{
    if (tokenArray != tokenArray_){
        [self _setTokenArray: tokenArray];
        
        id fieldEditor = [[self cell] fieldEditorForView:self] ;
            if ([fieldEditor delegate] == self)
                [(_MTTokenTextView*)[[self cell] fieldEditorForView:self] setTokenArray:tokenArray];

    }
    
}

-(void)setObjectValue:(NSArray*)tokenArray{
    [self setTokenArray:tokenArray];
}
-(NSArray*)objectValue{
    return [self tokenArray];;
    
}

+(Class)cellClass{
    return [MTTokenFieldCell class];   
}

-(void)awakeFromNib{
    [self setFont:[NSFont systemFontOfSize:11]];

}

-(BOOL)textShouldBeginEditing:(NSText *)textObj{
   return YES;
}


- (BOOL)textShouldEndEditing:(NSText *)textObj{
    return YES;
}




-(NSMenu*)menuForEvent:(NSEvent*)theEvent{
    
    
    if ([theEvent type] == NSRightMouseDown){
        
        
        static NSTextStorage * _static_textStore_= nil;
        static NSTextContainer * _static_textContainer_= nil;
        static NSLayoutManager * _static_textLayout_= nil;
        if (!_static_textStore_){
            _static_textStore_ = [[NSTextStorage alloc] init] ;
            _static_textContainer_ = [[NSTextContainer alloc] initWithContainerSize:NSZeroSize]   ;
            _static_textLayout_ = [[NSLayoutManager alloc] init];
            [_static_textLayout_ addTextContainer:_static_textContainer_];
            [_static_textStore_ addLayoutManager:_static_textLayout_];
            [_static_textContainer_ setLineFragmentPadding:0.0];
            
        }

        [_static_textStore_ setAttributedString:[self attributedStringValue]];
        
        [_static_textContainer_ setContainerSize:[self bounds].size];
        
        
        NSPoint pos = [self convertPoint:[theEvent  locationInWindow]
                                fromView:nil];
        NSUInteger glyphIndex = [_static_textLayout_ glyphIndexForPoint:pos inTextContainer:_static_textContainer_];
        
        NSUInteger charIndex = [_static_textLayout_ characterIndexForGlyphAtIndex:glyphIndex];
        
        
        _MTTokenTextAttachment* attribute = [_static_textStore_ attribute:NSAttachmentAttributeName atIndex:charIndex effectiveRange:nil];
        if (attribute && [attribute isKindOfClass:[_MTTokenTextAttachment class]]) {
            NSUInteger tokenIndex = [[self attributedStringValue] countOfMTTokensInRange:NSMakeRange(0,charIndex)];
            if ([[self delegate] respondsToSelector:@selector(tokenField:menuForToken:atIndex:)]){
                return [(id <MTTokenFieldDelegate>) [self delegate] tokenField:self menuForToken:[(_MTTokenTextAttachmentCell*)[attribute attachmentCell] tokenTitle] atIndex:tokenIndex];
            }
        }
    }
    return [super menuForEvent:theEvent];
}


@end
