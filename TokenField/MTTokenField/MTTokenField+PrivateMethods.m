//
//  MTTokenField+PrivateMethods.m
//  MailTags
//
//  Created by smorr on 12-01-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MTTokenField+PrivateMethods.h"
#import "_MTTokenTextAttachment.h"

@implementation MTTokenField (PrivateMethods)

-(void)_setTokenArray:(NSArray*)tokenArray{
    if (tokenArray != tokenArray_){
        id oldArray = tokenArray_;
        tokenArray_= [tokenArray retain];
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] init];
        
        for (id atoken in tokenArray){
            
            _MTTokenTextAttachment * ta = [[_MTTokenTextAttachment alloc] initWithTitle:atoken ];
            
            NSMutableAttributedString*  tokenString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:ta]];
            [tokenString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithInt:0] range:NSMakeRange(0, [tokenString length])];
            
            [tokenString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithInt:0] range:NSMakeRange(0, [tokenString length])];
            [ta release];
            
            
        
            [attributedString appendAttributedString:tokenString];
            [tokenString release];
            [self setNeedsDisplay:YES];
        }
        [self setAttributedStringValue:attributedString];
        [attributedString release];
        [oldArray release];
    }
}
-(BOOL)shouldAddToken:(NSString*)token atTokenIndex:(NSUInteger)index{
    if ([[self delegate] respondsToSelector:@selector(tokenField:shouldAddToken:atIndex:)]){
        return  [(id <MTTokenFieldDelegate>)[self delegate] tokenField:self shouldAddToken:token atIndex:index];
    }
    return YES;
    
}
-(void)textView:(_MTTokenTextView*)textView didChangeTokens:(NSArray*)tokens{
    if ([[self delegate] respondsToSelector:@selector(tokenField:willChangeTokens:)]){
        [[self delegate] performSelector:@selector(tokenField:willChangeTokens:) withObject:self withObject:tokens];
     
    }
    [self _setTokenArray:tokens];
    if ([[self delegate] respondsToSelector:@selector(tokenField:didChangeTokens:)]){
        [[self delegate] performSelector:@selector(tokenField:didChangeTokens:) withObject:self withObject:tokens];
    }
}

-(NSMenu*)textView:(NSTextView *)aTextView menuForToken:(NSString*) string atIndex:(NSUInteger) index{
    if ([[self delegate] respondsToSelector:@selector(tokenField:menuForToken:atIndex:)]){
        return [(id <MTTokenFieldDelegate>) [self delegate] tokenField:self menuForToken:(NSString*) string atIndex:(NSUInteger) index];
    }
    return nil;
    
}

@end
