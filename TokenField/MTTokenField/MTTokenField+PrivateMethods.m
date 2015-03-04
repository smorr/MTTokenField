//
//  MTTokenField+PrivateMethods.m
//  MailTags
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
