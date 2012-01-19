//
//  NSAttributedString+MTTokenField.m
//  TokenField
//
//  Created by smorr on 12-01-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
