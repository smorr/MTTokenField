//
//  NSAttributedString+MTTokenField.m
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

#import "NSAttributedString+MTTokenField.h"
#import "_MTTokenTextAttachment.h"

@implementation NSAttributedString (MTTokenField)
-(NSUInteger)countOfMTTokensInRange:(NSRange)aRange{
    if (aRange.location ==0) return 0;
    NSUInteger count = 0;
    
    NSRange curRange = NSMakeRange(aRange.location+aRange.length-1,0);
    
    while (curRange.location!=NSNotFound && curRange.location>=aRange.location ){
        if (curRange.location < [self length]){
            id attribute= [self attribute:NSAttachmentAttributeName atIndex:curRange.location effectiveRange:&curRange];
            if ([attribute isKindOfClass:[_MTTokenTextAttachment class] ]) count++;
        }
        curRange = NSMakeRange(curRange.location>0?curRange.location-1:NSNotFound, 0);
    }
    return count;
    
    
}
@end
