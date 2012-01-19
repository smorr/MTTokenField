//
//  MTAppDelegate.m
//  TokenField
//
//  Created by smorr on 11-11-29.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
    self.tokensForCompletion = [NSMutableArray arrayWithObjects:@"A very long keyword",@"Änger",@"Blatt",@"test",@"tiara",@"typhoon",@"trick",@"trigger",@"🕚tiger",@"@tickle",@"@waiting",@"@Followup",@"Walrus", nil];  
    
    [self.myTokenField setTokenArray:[NSArray arrayWithObject:@"test"]];
    
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
