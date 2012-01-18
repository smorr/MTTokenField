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
    
    
    [self.tableView reloadData];
        
    
    
    
    // Insert code here to initialize your application
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [self.tokensForCompletion count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row   {
    return [self.tokensForCompletion  objectAtIndex:row];
}


- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex{
    return [self tokenField:tokenField completionsForSubstring:substring];
}
- (NSArray *)tokenField:(MTTokenField *)tokenField completionsForSubstring:(NSString *)substring 
{
    NSArray * testArray = self.tokensForCompletion;
    if (self.option==0){
        NSMutableArray * keywordsMatchingString = [[[NSMutableArray alloc] init] autorelease];
        for (NSString *aKeyword in testArray){
            if ([aKeyword rangeOfString:substring options:NSCaseInsensitiveSearch].location !=NSNotFound){
                [keywordsMatchingString addObject:aKeyword];  
            }
        }
        return keywordsMatchingString;
        
    }
    else{
    
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
        
        NSMutableArray * keywordsMatchingString = [[[NSMutableArray alloc] init] autorelease];;
        for (NSString *aKeyword in testArray){
            if ([tokenField respondsToSelector:@selector(tokenArray)]){
                if([[tokenField tokenArray] containsObject:aKeyword]) continue;
            }
            else{
                if([[tokenField objectValue] containsObject:aKeyword]) continue;
            }
            
            NSRange alphaNumericRange = [aKeyword rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]];
            if (alphaNumericRange.location!=NSNotFound){
                NSString * alphaKeyword = searchFullString?aKeyword:[aKeyword substringFromIndex:alphaNumericRange.location];
                NSRange substringRange = [alphaKeyword rangeOfString:alphaSubstring options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
                if (substringRange.location == 0){
                    [keywordsMatchingString addObject:aKeyword];
                }
            }
           
        }
     
    return keywordsMatchingString; 
    }
        
}

-(IBAction)click:(id)sender{
    [myTokenField setTokenArray:[NSArray arrayWithObject:@"blatt"]];
}

@end
