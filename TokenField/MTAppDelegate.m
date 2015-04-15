//
//  MTAppDelegate.m
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

#import "MTAppDelegate.h"
@implementation MTAppDelegate
@synthesize myTokenField;
@synthesize standardTokenField,tableView;
@synthesize window = _window;
@synthesize tokensForCompletion;
@synthesize option;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.tokensForCompletion = [NSMutableArray arrayWithObjects:@"Blatt",@"test",@"tiara",@"typhoon",@"trick",@"trigger",@"🕚tiger",@"@tickle",@"@Action",@"apt",@"apple-gala",@"apple-fuji",@"@waiting",@"@Followup",@"Walrus",@"Responde",@"Répondre", nil];
    
    [self.myTokenField setTokenArray:@[]];
     self.option = 1;
    [self.tableView reloadData];
   
    
    
    
    // Insert code here to initialize your application
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [self.tokensForCompletion count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row   {
    return [self.tokensForCompletion  objectAtIndex:row];
}

- (NSArray *)tokenField:(MTTokenField*)tokenField completionsForSubstring:(NSString *)substring 
{
    NSArray * testArray = self.tokensForCompletion;
    if (self.option==0){
        // matching substring to anyportion of the candidate
        NSMutableArray * matches = [[[NSMutableArray alloc] init] autorelease];
        for (NSString *candidate in testArray){
            if ([candidate rangeOfString:substring options:NSCaseInsensitiveSearch].location !=NSNotFound){
                [matches addObject:candidate];  
            }
        }
        return matches;
        
    }
    else{
        // matching substring to leading characters of candidate ignoring any non AlphaNumeric characters in candidate
        // eg
        // if substring is "ac",   matches will include "@action" and "account" but not "fact"
        
        NSRange alphaNumericRange = [substring rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]];
        NSString * alphaSubstring = @"";
        
        BOOL searchFullString = NO;
        if (alphaNumericRange.location!=NSNotFound){
            alphaSubstring = [substring substringFromIndex:alphaNumericRange.location];
        }
        else{
            alphaSubstring = substring;
            searchFullString = YES;
        }
        
        NSMutableArray * matches = [[[NSMutableArray alloc] init] autorelease];;
        for (NSString *candidate in testArray){
            // remove any candidate already in use
            if ([tokenField respondsToSelector:@selector(tokenArray)]){
                if([[tokenField tokenArray] containsObject:candidate]) continue;
            }
            else{
                if([[tokenField objectValue] containsObject:candidate]) continue;
            }
            
            
            
            NSRange alphaNumericRange = [candidate rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]];
            if (alphaNumericRange.location!=NSNotFound){
                NSString * alphaKeyword = searchFullString?candidate:[candidate substringFromIndex:alphaNumericRange.location];
                NSRange substringRange = [alphaKeyword rangeOfString:alphaSubstring options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
                if (substringRange.location == 0){
                    [matches addObject:candidate];
                }
            }
            
        }
        
        return matches; 
    }
    
}
-(void)action:(id)sender{
    NSLog(@"You selected Menu Item: %@",sender);
}

-(MTTokenStyle)tokenField:(MTTokenField*) tokenField styleForToken:(NSString*) string {
    if ([string rangeOfString:@"tri"].location!=NSNotFound){
        return kMTTokenStyleRoundedColor;
    }
    if ([string rangeOfString:@"Blatt"].location!=NSNotFound){
        return kMTTokenStyleRounded;
    }

    return kMTTokenStyleRectangular;
}


-(NSColor*)tokenField:(MTTokenField *)tokenField colorForToken:(NSString *)string{
    if ([string rangeOfString:@"test"].location!=NSNotFound){
        return [NSColor colorWithCalibratedRed:.588 green:0.749 blue:0.929 alpha:1.000];
    }
    if ([string rangeOfString:@"trick"].location!=NSNotFound){
        return [NSColor redColor];
    }
    
        return [NSColor yellowColor];

}

-(NSMenu*)tokenField:(MTTokenField *)tokenField menuForToken:(NSString*) string atIndex:(NSUInteger) index{
    NSMenu * test = [[[NSMenu alloc] init] autorelease];
    NSArray * itemNames = [NSArray arrayWithObjects:@"Cut",@"Copy",@"Paste",@"-", [NSString stringWithFormat:@"Add %@ to preferences",string], nil];
    for (NSString *aName in itemNames){
        if ([aName isEqualToString:@"-"]){
            [test addItem:[NSMenuItem separatorItem]];
        }
        else{
            NSMenuItem * item = [[NSMenuItem alloc] initWithTitle:aName action:@selector(action:) keyEquivalent:@""];
            [item setTarget:self];
            [test addItem:item];
            [item release];

        
        }
    }
    return test;
}


- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex{
    return [self tokenField:(id)tokenField completionsForSubstring:substring];
}

-(IBAction)click:(id)sender{
    [myTokenField setTokenArray:[NSArray arrayWithObject:@"blatt"]];
}

@end
