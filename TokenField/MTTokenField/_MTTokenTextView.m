//
//  MTTokenTextView.m
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

#import "_MTTokenTextView.h"
#import "MTTokenField.h"
#import "_MTTokenCompletionWindowController.h"
#import "_MTTokenTextAttachment.h"
#import "MTTokenField+PrivateMethods.h"
#import "NSAttributedString+MTTokenField.h"

@interface _MTTokenTextView(private)
-(MTTokenField*)delegate;

@end

@implementation _MTTokenTextView

-(NSAttributedString*)tokenForString:(NSString*)aString{	
	_MTTokenTextAttachment * ta = [[_MTTokenTextAttachment alloc] initWithTitle:aString ];
    
    NSMutableAttributedString*  as = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:ta]];
    
    MTTokenField * controlView = (MTTokenField *)[self delegate];
    if ([controlView respondsToSelector:@selector(delegate)]){
        id <MTTokenFieldDelegate> controlViewDelegate = (id <MTTokenFieldDelegate>)[controlView delegate];
        if ([controlViewDelegate respondsToSelector:@selector(tokenField:colorForToken:)]){
            ta.color = [controlViewDelegate tokenField:controlView colorForToken:aString ];
         }
        if ([controlViewDelegate respondsToSelector:@selector(tokenField:styleForToken:)]){
            ta.style = [controlViewDelegate tokenField:controlView styleForToken:aString ];
        }

    }
    
    [as addAttribute:NSAttachmentAttributeName value:ta range:NSMakeRange(0, [as length])];
	[as addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithInt:0] range:NSMakeRange(0, [as length])];
	[ta release];
	
	return [as autorelease];;
}


-(void)dealloc{
    self.components = nil;
    [super dealloc];
}

-(id)init{
    self = [super init];
    if (self){
        [[self textStorage] setFont:[NSFont systemFontOfSize:11]];
        self.components = [NSMutableArray array];
        self.nibAttributes = @{NSFontAttributeName:[NSFont systemFontOfSize:11]};
    }
    return self;
}

-(void)awakeFromNib{
    self.nibAttributes = [self.textStorage attributesAtIndex:0 effectiveRange:nil];
}
-(NSArray *)getCompletionsForStem:(NSString*)stem{
    MTTokenField * controlView = (MTTokenField *)[self delegate];
    if ([controlView respondsToSelector:@selector(delegate)]){
        id <MTTokenFieldDelegate> controlViewDelegate = (id <MTTokenFieldDelegate>)[controlView delegate];
        if ([controlViewDelegate respondsToSelector:@selector(tokenField:completionsForSubstring:)]){
            NSArray * result = [controlViewDelegate tokenField:controlView completionsForSubstring:stem];
            return result;
        }
    }
    return [NSArray array];
}

-(NSUInteger)componentIndexForLocation:(NSUInteger)searchLocation{
    NSAttributedString * curString = [self textStorage];
    if (searchLocation>=[curString length]) return NSNotFound;

    NSUInteger componentIndex = 0;
    NSUInteger location =0;
    
    BOOL lastComponentWasToken = NO;
    
    while (location < [curString length]){
       
        if ([curString attribute:NSAttachmentAttributeName atIndex:location effectiveRange:nil]){
            componentIndex++;
            lastComponentWasToken=YES;
        }
        else if (lastComponentWasToken){
            componentIndex++;
            lastComponentWasToken=NO;
       }
        if (location>=searchLocation){
            return componentIndex;
        }
        location++;
    }
    return componentIndex;
}




-(NSRange)rangeForCompletion{
    NSRange effectiveRange =[self selectedRange];
    NSUInteger startLocation = effectiveRange.location;
    NSUInteger endLocation = effectiveRange.location;
    NSAttributedString * curString = [self textStorage];
    while (startLocation && ![curString attribute:NSAttachmentAttributeName atIndex:startLocation-1 effectiveRange:nil]){
        startLocation--;
    }
    while (endLocation < [curString length] && ![curString attribute:NSAttachmentAttributeName atIndex:endLocation effectiveRange:nil]){
        endLocation++;
    }
    return NSMakeRange(startLocation, endLocation-startLocation);
    
    
}
-(NSRange)forwardCompletionRange{
    NSRange effectiveRange =[self selectedRange];
    NSRange lastRange=effectiveRange;
    if (effectiveRange.location<[[self textStorage]length]){
        if ([[self textStorage] attribute:NSAttachmentAttributeName atIndex:effectiveRange.location effectiveRange:&lastRange]){
            lastRange.length =0;
        }
        
        while (effectiveRange.location<[[self textStorage]length]){
            NSRange fullrange;
            if([[self textStorage] attribute:NSAttachmentAttributeName atIndex:effectiveRange.location effectiveRange:&fullrange]){
                break;
            }
            else{
            }
            if(fullrange.location+fullrange.length<[[self textStorage]length]){
                lastRange = fullrange;
                effectiveRange.location=fullrange.location+fullrange.length;
                effectiveRange.length = 0;
            }
            else{
                break;
            }
        }
        if (lastRange.location == NSNotFound){
            lastRange.location=0;
        }
    }
    return lastRange;
}

-(NSUInteger)countOfTokensInRange:(NSRange)aRange{
    return [[self textStorage] countOfMTTokensInRange:aRange];
}
-(NSRange)completionRange{
    
    
    NSRange effectiveRange =[self selectedRange];
    // scan backwards looking for the first attachment (ie token)
    while (effectiveRange.location !=NSNotFound && effectiveRange.location>0){
        NSDictionary *attr = [[self textStorage] attributesAtIndex:effectiveRange.location-1 effectiveRange:&effectiveRange];
        if ([attr objectForKey:NSAttachmentAttributeName]){
            // found an attachment - 
            effectiveRange.location+=effectiveRange.length;
            break;
        }
    }
    if (effectiveRange.location == NSNotFound){
        effectiveRange.location=0;
    }
    effectiveRange.length = [self selectedRange].location-effectiveRange.location;
    if ([self hasMarkedText]){
        // adjustment if their is marked text (dead keys etc) in string
        NSRange markedRange =[self markedRange];
        if (markedRange.location !=NSNotFound){
            effectiveRange.length = markedRange.location - effectiveRange.location;
        }
     }
    return effectiveRange;
 }

-(NSString*)completionStem{
    NSUInteger strLen =[[[self textStorage] string] length];
    NSRange completionRange = [self completionRange];
    if (completionRange.location+completionRange.length-1>strLen){
        return @"";
    }
    NSString * stem =[[[self textStorage] string] substringWithRange:completionRange];
    return stem;
}

-(void)insertTextWithoutCompletion:(id)aString{
    [super insertText:aString replacementRange:NSMakeRange([[[self textStorage] string] length],0)];
}

-(void)insertText:(id)aString replacementRange:(NSRange)replacementRange andBeginCompletion:(BOOL)beginCompletionFlag{
    NSUInteger insertionIndex = [self selectedRange].location;
    if (insertionIndex !=NSNotFound){
        _MTTokenCompletionWindowController* completionController = [_MTTokenCompletionWindowController sharedController];
        BOOL isShowingCompletions =[completionController completionWindow]!=nil;
        
        if (isShowingCompletions){
            [completionController insertText:aString];
        }
        else{
             NSRange  startingStemRange = [self rangeForCompletion];
            NSUInteger selectionIndex = self.selectedRange.location - startingStemRange.location;
            
            NSMutableString * startingStem =[[[[[self textStorage] string] substringWithRange:startingStemRange] mutableCopy] autorelease];
            [startingStem insertString:aString atIndex:selectionIndex];
           // NSLog (@"Not showing completions -- setting raw text" );
                   
            [completionController insertText:startingStem];
            
        }
        
        NSString * rawString = [aString respondsToSelector:@selector(string)]?[aString string]:aString;
 
        if (insertionIndex<=[[self textStorage] length]){
            NSRange stemRange = [self completionRange];
            NSString * stem =[[self completionStem]  stringByAppendingString:rawString];
        
            [completionController setTokenizingCharacterSet:[(MTTokenField*)[self delegate] tokenizingCharacterSet]];
            [completionController displayCompletionsForStem: completionController.rawStem forTextView:self forRange:stemRange];
            if([[completionController completionsArray] count]==0){
                if (!isShowingCompletions){
                    [super insertText:aString replacementRange:replacementRange];
                }
            }
            return;
        }
    }
    [super insertText:aString replacementRange:replacementRange];
}

-(void)removeTokenForText:(NSString*)tokenText{
    BOOL changed = NO;
    if ([[self textStorage] length]){
        NSRange curRange = NSMakeRange([[self textStorage] length]-1,0);
        while (curRange.location!=NSNotFound ){
            id attribute= [[self textStorage] attribute:NSAttachmentAttributeName atIndex:curRange.location effectiveRange:&curRange];
            if (attribute && [[attribute  title] isEqualToString:tokenText]){
                [[self textStorage] replaceCharactersInRange:curRange withString:@""];
                changed = YES;
            }
            curRange = NSMakeRange(curRange.location>0?curRange.location-1:NSNotFound, 0);
        }
        
    }
    if (changed){
        [(MTTokenField*)[self delegate] textView:self didChangeTokens: [self tokenArray]];

    }
}


-(void) insertTokenForText:(NSString*)tokenText replacementRange:(NSRange)replacementRange{
    if ([(MTTokenField*)[self delegate] shouldAddToken: tokenText atTokenIndex:[self countOfTokensInRange:NSMakeRange(0,replacementRange.location)] ]){
        NSAttributedString *insertionText = [self tokenForString:tokenText];
        [super insertText:insertionText replacementRange:replacementRange];
        [(MTTokenField*)[self delegate] textView:self didChangeTokens: [self tokenArray]];
    }
}
-(void)insertText:(id)aString replacementRange:(NSRange)replacementRange {
     if ([[_MTTokenCompletionWindowController sharedController] isDisplayingCompletions]){
         NSLog (@"3 MarkedRange: %@",NSStringFromRange([self markedRange]));
         [self insertText:aString replacementRange:replacementRange andBeginCompletion:YES];
         return;
    }
    else{
        [self insertText:aString replacementRange:replacementRange andBeginCompletion:YES];
    }
    
}


- (void)setMarkedText:(id)aString selectedRange:(NSRange)selectedRange replacementRange:(NSRange)replacementRange{
    [super setMarkedText:aString selectedRange:selectedRange replacementRange:replacementRange];
}


-(void)abandonCompletion{
    //NSLog (@"abandon completion");
    _MTTokenCompletionWindowController * completionController = [_MTTokenCompletionWindowController sharedController];
    
    if ([completionController isDisplayingCompletions]){
        NSRange deleteRange = self.rangeForCompletion;
        [self.textStorage replaceCharactersInRange:deleteRange withString:completionController.rawStem];
        NSRange rangeForAttributes = self.rangeForCompletion;
        [self.textStorage setAttributes:self.nibAttributes range:rangeForAttributes];
        [self setSelectedRange:NSMakeRange(MIN(self.textStorage.length,rangeForAttributes.location+rangeForAttributes.length+1),0)];
        [completionController tearDownWindow];
    }
    
}

-(void)insertText:(id)aString{
    //NSLog (@"4 insertText: %@ MarkedRange: %@",aString,NSStringFromRange([self markedRange]));
    
    if ([self markedRange].length>0){
        [self insertText:aString replacementRange:self.markedRange andBeginCompletion:YES];
        return;
    }
    
    if ([[_MTTokenCompletionWindowController sharedController] isDisplayingCompletions]){
        if ([self markedRange].length>0){
            [self insertText:aString replacementRange:self.markedRange andBeginCompletion:YES];
            //[super insertText:aString replacementRange:self.markedRange];
        }
        else{
            [self insertText:aString replacementRange:[self selectedRange] andBeginCompletion:YES];
        }
        return;
    }
    NSUInteger insertionIndex = [self selectedRange].location;
    if (insertionIndex !=NSNotFound){
        if ([[self textStorage] length]==insertionIndex){
            NSRange stemRange = [self completionRange];
            
            if ([aString length]==1 && [[(MTTokenField*)[self delegate] tokenizingCharacterSet] characterIsMember:[aString characterAtIndex:0]]){
                if(stemRange.length >0){
                    if ([(MTTokenField*)[self delegate] shouldAddToken: [self completionStem ] atTokenIndex:[self countOfTokensInRange:NSMakeRange(0,insertionIndex)] ]){
                        NSAttributedString *insertionText = [self tokenForString:[self completionStem]];
                        [[self textStorage] replaceCharactersInRange:stemRange withAttributedString:insertionText];
                    }
                }
              }
            else{
               // NSString * stem =[[self completionStem]  stringByAppendingString:aString];
                [[_MTTokenCompletionWindowController sharedController] setTokenizingCharacterSet:[(MTTokenField*)[self delegate] tokenizingCharacterSet]];
                 [self insertText:aString replacementRange:[self selectedRange] andBeginCompletion:YES];
              //  [[_MTTokenCompletionWindowController sharedController] displayCompletionsForStem: stem forTextView:self forRange:stemRange];
            }
            return;
        }
        else if (insertionIndex<[[self textStorage] length]){
             NSRange stemRange = [self completionRange];
            if ([aString length]==1 && [[(MTTokenField*)[self delegate] tokenizingCharacterSet] characterIsMember:[aString characterAtIndex:0]]){
                if(stemRange.length >0){
                    if ([(MTTokenField*)[self delegate] shouldAddToken: [self completionStem ] atTokenIndex:[self countOfTokensInRange:NSMakeRange(0,insertionIndex)] ]){
                        NSAttributedString *insertionText = [self tokenForString:[self completionStem]];
                        [[self textStorage] replaceCharactersInRange:stemRange withAttributedString:insertionText];
                    }
                }
            }
            else{
                if ([[self textStorage] attribute:NSAttachmentAttributeName atIndex:insertionIndex effectiveRange:nil]){
                   // NSRange stemRange = [self completionRange];
                   // NSString * stem =[[self completionStem]  stringByAppendingString:aString];
                    [[_MTTokenCompletionWindowController sharedController] setTokenizingCharacterSet:[(MTTokenField*)[self delegate] tokenizingCharacterSet]];
                      [self insertText:aString replacementRange:[self selectedRange] andBeginCompletion:YES];
//                    [[_MTTokenCompletionWindowController sharedController] displayCompletionsForStem:stem forTextView:self forRange:stemRange];
                }
                else{
                    // just insert the text without completing -- don't call super insertText as that will start a completion by default.
                     [self insertText:aString replacementRange:[self selectedRange] andBeginCompletion:YES];
                    //[super insertText:aString replacementRange:[self selectedRange] ];
                }
            }
             return;
            
        }
    }
    [(MTTokenField*)[self delegate] textView:self didChangeTokens: [self tokenArray]];
    [super insertText:aString];
}


-(NSArray*)tokenArray{
    NSMutableArray * tokenArray = [NSMutableArray array];
    
    if ([[self textStorage] length]){
        NSRange curRange = NSMakeRange([[self textStorage] length]-1,0);
        while (curRange.location!=NSNotFound ){
            id attribute= [[self textStorage] attribute:NSAttachmentAttributeName atIndex:curRange.location effectiveRange:&curRange];
            if (attribute) [tokenArray insertObject: [attribute title] atIndex:0];
            curRange = NSMakeRange(curRange.location>0?curRange.location-1:NSNotFound, 0);
        }
    }
    return tokenArray;
    
}
-(void)setTokenArray:(NSArray*)tokenArray{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] init];
    
    for (id atoken in tokenArray){
        NSAttributedString *insertionText = [self tokenForString:atoken];
        [attributedString appendAttributedString:insertionText];
    }
    [[self textStorage] setAttributedString:attributedString];
    [attributedString release];
    
}


-(void)tokenizeRemainingText{
    if ([[self textStorage] length]){
        NSRange curRange = NSMakeRange([[self textStorage] length]-1,0);
        while (curRange.location!=NSNotFound ){
            if(![[self textStorage] attribute:NSAttachmentAttributeName atIndex:curRange.location effectiveRange:&curRange]){
                if ([(MTTokenField*)[self delegate] shouldAddToken: [self completionStem ] atTokenIndex:[self countOfTokensInRange:NSMakeRange(0,curRange.location)] ]){
                    NSString *string = [[[self textStorage] string] substringWithRange:curRange];
                    NSAttributedString *insertionText = [self tokenForString:string];
                    
                    [[self textStorage] replaceCharactersInRange:curRange withAttributedString:insertionText];
                }
               
            }
            curRange = NSMakeRange(curRange.location>0?curRange.location-1:NSNotFound, 0);
            
        }
    }
    [(MTTokenField*)[self delegate] textView:self didChangeTokens: [self tokenArray]];
    
}
-(void)commitTokens{
    [self tokenizeRemainingText];
}

-(BOOL)resignFirstResponder{
    [self tokenizeRemainingText];
    return [super resignFirstResponder];
}


-(void)doCommandBySelector:(SEL)aSelector{
    _MTTokenCompletionWindowController * completionController = [_MTTokenCompletionWindowController sharedController];
    if (aSelector == @selector(deleteBackward:)){
        
        NSArray * currentTokens = [self tokenArray];
        __unused NSUInteger ci = [self componentIndexForLocation:7];
        
        
        if (self.selectedRange.length>0  ){
            NSRange deleteRange = self.selectedRange;
            [self.textStorage replaceCharactersInRange:deleteRange withString:@""];
            [self setSelectedRange:NSMakeRange(deleteRange.location,0)];
            if (completionController.isDisplayingCompletions){
                [self abandonCompletion];
            }
        }else{
            if (self.selectedRange.location>0){
                NSUInteger deleteIndex = self.selectedRange.location-1;
                if ([self.textStorage tokenStringAtIndex:deleteIndex]){
                    [self.textStorage replaceCharactersInRange:NSMakeRange(deleteIndex, 1)  withString:@""];
                }
                else{
                    NSRange deleteRange = [[self.textStorage string] rangeOfComposedCharacterSequenceAtIndex:deleteIndex];
                    [self.textStorage replaceCharactersInRange:deleteRange withString:@""];
                    [self setSelectedRange:NSMakeRange(deleteRange.location,0)];
                    [completionController tearDownWindow];
                    //[self abandonCompletion];
                }
            }
        }
        
        if (![currentTokens isEqualToArray:[self tokenArray]]){
           [(MTTokenField*)[self delegate] textView:self didChangeTokens: [self tokenArray]];
        }
        return;
    }

    if (aSelector   == @selector(moveLeft:)){
        
        // reset displayed text to the rawstem
        
        
        [self abandonCompletion];
        
        NSRange selRange = [self selectedRange];
        if (selRange.location>0 && selRange.location<[[self textStorage] length]){
            if ([[self textStorage] attribute:NSAttachmentAttributeName atIndex:selRange.location-1 effectiveRange:nil]){
                NSRange completionRange = [self rangeForCompletion];
                if (completionRange.length>0){
                    NSString *string = [[[self textStorage] string] substringWithRange:completionRange];
                    if ([(MTTokenField*)[self delegate] shouldAddToken: [self completionStem ] atTokenIndex:[self countOfTokensInRange:NSMakeRange(0,completionRange.location)] ]){

                        NSAttributedString *insertionText = [self tokenForString:string];
                        [[self textStorage] replaceCharactersInRange:[self completionRange] withAttributedString:insertionText];
                        [(MTTokenField*)[self delegate] textView:self didChangeTokens: [self tokenArray]];
                     }
                    
                }
            }
        }
    }
    if ( aSelector  == @selector(insertTab:)) {
        id kv = [(MTTokenField*)[self delegate] nextValidKeyView];
        [[(NSView*)[self delegate] window] makeFirstResponder:kv ];
        return;
    }
    if ( aSelector  == @selector(insertBacktab:)) {
        id kv = [(MTTokenField*)[self delegate] previousValidKeyView];
        [[(NSView*)[self delegate] window] makeFirstResponder:kv ];
        return;
    }
    if ( aSelector  == @selector(insertNewline:)) {
        if ([[self completionStem] length]){
            NSRange completionRange = [self rangeForCompletion];
            if ([(MTTokenField*)[self delegate] shouldAddToken: [self completionStem ] atTokenIndex:[self countOfTokensInRange:NSMakeRange(0,completionRange.location)] ]){

                NSAttributedString *insertionText = [self tokenForString:[self completionStem]];
                [[self textStorage] replaceCharactersInRange:completionRange withAttributedString:insertionText];
                [(MTTokenField*)[self delegate] textView:self didChangeTokens: [self tokenArray]];
            }
        }
            
        return;
    }
    [super doCommandBySelector:aSelector];
}

-(NSMenu*)menuForEvent:(NSEvent*)theEvent{
    if ([theEvent type] == NSRightMouseDown){
        NSPoint pos = [self convertPoint:[theEvent  locationInWindow]
                                    fromView:nil];
        NSUInteger glyphIndex = [[self layoutManager] glyphIndexForPoint:pos inTextContainer:[self textContainer]];
        if (glyphIndex !=NSNotFound){
            NSUInteger charIndex = [[self layoutManager] characterIndexForGlyphAtIndex:glyphIndex];
            if (charIndex !=NSNotFound){
                _MTTokenTextAttachment* attribute = [[self textStorage] attribute:NSAttachmentAttributeName atIndex:charIndex effectiveRange:nil];
                if (attribute && [attribute isKindOfClass:[_MTTokenTextAttachment class]]) {
                    NSUInteger tokenIndex = [self countOfTokensInRange:NSMakeRange(0,charIndex)];
                    NSMenu * menu = [[self delegate] textView:self menuForToken:[(_MTTokenTextAttachmentCell*)[attribute attachmentCell] tokenTitle] atIndex:tokenIndex];
                    return menu;
                }
            }
        }
    }
    return [super menuForEvent:theEvent];
}

-(void)mouseDown:(NSEvent*)theEvent{
    [super mouseDown:theEvent];
}

@end
