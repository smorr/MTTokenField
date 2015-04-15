//
//  MTTokenFieldDelegate.h
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

#import <Foundation/Foundation.h>
@class MTTokenField;

typedef NS_ENUM(NSUInteger, MTTokenStyle) {
    kMTTokenStyleRounded = 0,
    kMTTokenStyleRectangular = 1,
    kMTTokenStyleRoundedColor = 2,
    kMTTokenStyleRoundedLeftSideColor = 3
};

@protocol MTTokenFieldDelegate <NSObject,NSTextFieldDelegate>
@optional

-(NSArray *)tokenField:(MTTokenField *)tokenField completionsForSubstring:(NSString *)substring;

-(void)tokenField:(MTTokenField *) tokenField didChangeTokens:(NSArray*)tokens;

-(void)tokenField:(MTTokenField *) tokenField willChangeTokens:(NSArray*)tokens;

-(BOOL)tokenField:(MTTokenField *) tokenField shouldAddToken:(NSString *)token atIndex:(NSUInteger)index;

-(NSMenu*)tokenField:(MTTokenField *)tokenField menuForToken:(NSString*) string atIndex:(NSUInteger) index;

-(NSColor*)tokenField:(MTTokenField*) tokenField colorForToken:(NSString*) string;

-(MTTokenStyle)tokenField:(MTTokenField*) tokenField styleForToken:(NSString*) string ;



@end
