MTTokenField is a replacement for AppKit's NSTokenField

###Rationale
NSTokenField has several limitations for autocompletion and display of tokens.  
* Autocompletion handling non-alphanumeric prefixes for suggestions.   In MailTags, we wanted users to be able to omit prefixes to token that were not Alphanumeric in nature (eg symbols such as '@' and emoji)  so that when they typed Act... the keyword '@Action' would be presented as an autocompletion option.
* Display of different colours and token styles for tokenized strings and the autocompletion suggestions. 

###Sample Image
<img src="https://github.com/smorr/MTTokenField/blob/master/TokenField/SampleMTTokenField.png" height="70"  >


###Usage

* Add the MTTokenField classes to your project.  
* Add an NSTextField to your view.  Set its class to MTTokenField
* Set the delegate of the MTTokenField to the object (which implements the MTTokenFieldDelegate protocol) to provide autocompletions, colors, styles etc.
* In the MTTokenField delegate, implement the following optional methods:

```
-(NSArray *)tokenField:(MTTokenField *)tokenField completionsForSubstring:(NSString *)substring;

-(void)tokenField:(MTTokenField *) tokenField didChangeTokens:(NSArray*)tokens;

-(void)tokenField:(MTTokenField *) tokenField willChangeTokens:(NSArray*)tokens;

-(BOOL)tokenField:(MTTokenField *) tokenField shouldAddToken:(NSString *)token atIndex:(NSUInteger)index;

-(NSMenu*)tokenField:(MTTokenField *)tokenField menuForToken:(NSString*) string atIndex:(NSUInteger) index;

-(NSColor*)tokenField:(MTTokenField*) tokenField colorForToken:(NSString*) string;

-(MTTokenStyle)tokenField:(MTTokenField*) tokenField styleForToken:(NSString*) string ;
```



###License
Copyright (c) 2012-2015 Indev Software

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


##MTTokenField

MTTokenField is a replacement for NSTokenField to allow for better completion handling for stems that do not necessarily occur at the beginning of the completion options.

It was developed to better handle the problem of users employing non alphanumeric symbols or emoji as the leading character.

When I set the NSTokenField delegate to return completions that ignore leading symbols, the selection in the tokenfield behaves in such a way it make it difficult to continue typing for the autocompletion.

MTTokenfield handles this better.


###Caveat

This is still an incomplete implementation.

It doesn't handle drag and drop, copying the token array, rendering of tokens in a selected state etc.
