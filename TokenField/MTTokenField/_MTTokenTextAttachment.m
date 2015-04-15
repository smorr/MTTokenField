//
//  _MTTokenTextAttachment.m
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

#import "_MTTokenTextAttachment.h"
#import "NSColor+Shades.h"

@implementation _MTTokenTextAttachment
@synthesize representedObject,title;
-(id)initWithTitle:(NSString*)aTitle {
    self = [self init];
    if (self){
        title = [aTitle copy];
        _MTTokenTextAttachmentCell* tac = [[_MTTokenTextAttachmentCell alloc] init];
        tac.tokenTitle = title;
        [self setAttachmentCell: tac];
        [tac release];
    }
    return self;
}



-(id)description{
    return [NSString stringWithFormat:@"<%@ %p Title: %@ | cell: %@>",[self class]  ,self, self.title,[self attachmentCell]];
}
-(id)copyWithZone:(id)zone{
    return nil;
}
-(id)mutableCopy{
    return nil;
}
-(void)dealloc{
    self.representedObject = nil;
    self.title = nil;
    [super dealloc];
}
@end


@implementation _MTTokenTextAttachmentCell
@synthesize tokenTitle;
@synthesize selected;

-(void)dealloc{
    self.tokenTitle = nil;
    
    [super dealloc];
}


-(NSColor*)color{
    NSColor * tokenColor = nil;
    if ([self.attachment respondsToSelector:@selector(color)]){
        tokenColor = [(_MTTokenTextAttachment*)self.attachment color];
    }
    if (!tokenColor) {
        tokenColor = [NSColor colorWithCalibratedRed:0.851 green:0.906 blue:0.973 alpha:1.000];
    }
    return tokenColor;
}

-(MTTokenStyle)style{
    if ([self.attachment respondsToSelector:@selector(style)]){
        return [(_MTTokenTextAttachment*)self.attachment style];
    }
    else return kMTTokenStyleRounded;
    
}


-(NSPoint)cellBaselineOffset{
    NSPoint superPoint = [super cellBaselineOffset];
    superPoint.y -= 3.0;
    return superPoint;
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return [self retain];
}
-(id)copyWithZone:(NSZone *)zone{
    return [self retain];
}


-(NSImage*)standardTokenImage{
    static NSDictionary * _fontAttibutes = nil;
    if (!_fontAttibutes) _fontAttibutes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:11],NSFontAttributeName, nil];
    
    NSAttributedString * attributedString = [[[NSAttributedString alloc] initWithString:self.tokenTitle attributes:_fontAttibutes] autorelease];
    if (!attributedString)  return nil;
    CGFloat w = 19;
    
    NSSize imgSize =NSMakeSize([attributedString size].width+w+5, [attributedString size].height+0);
    if (imgSize.width == 0 || imgSize.height == 0)
        return nil;
    
    NSImage * image = [[[NSImage alloc] initWithSize:imgSize] autorelease];
    [image lockFocus];
    
    NSRect pathRect = NSMakeRect(2, 1, [attributedString size].width+w, [attributedString size].height-2);
    CGFloat radius = 6;
    NSBezierPath * path = [NSBezierPath bezierPath];
    
    CGFloat minimumX	= NSMinX(pathRect) - 0.5; // subtract half values to mitigate anti-aliasing
    CGFloat maximumX	= NSMaxX(pathRect) - 0.25;
    CGFloat minimumY	= NSMinY(pathRect) - 0.5;
    CGFloat maximumY	= NSMaxY(pathRect) - 0.5;
    CGFloat midY		= NSMidY(pathRect);
    CGFloat midX		= NSMidX(pathRect);
    
    // bottom right curve and bottom edge
    [path moveToPoint: NSMakePoint(midX, minimumY)];
    [path appendBezierPathWithArcFromPoint: NSMakePoint(maximumX, minimumY) toPoint: NSMakePoint(maximumX, midY) radius: radius-.5];
    
    // top right curve and right edge
    [path appendBezierPathWithArcFromPoint: NSMakePoint(maximumX, maximumY) toPoint: NSMakePoint(midX, maximumY) radius: radius-.5];
    
    // top left curve and top edge
    [path appendBezierPathWithArcFromPoint: NSMakePoint(minimumX, maximumY) toPoint: NSMakePoint(minimumX, midY) radius: radius];
    
    // bottom left curve and left edge
    [path appendBezierPathWithArcFromPoint: NSMakePoint(minimumX, minimumY) toPoint: NSMakePoint(midX, minimumY) radius: radius];
    [path closePath];
    
    
    
    [path setLineWidth:1.0];
    if (self.selected){
        [[NSColor colorWithCalibratedRed:0.671 green:0.706 blue:0.773 alpha:1.000] set];
    }
    else {
        [self.color set];
    }
    
    [path fill];
    [[NSColor colorWithCalibratedRed:.588 green:0.749 blue:0.929 alpha:1.000] set];
    [path stroke];
    [[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0]set];
    
    [attributedString drawInRect:NSMakeRect(11, 0, [attributedString size].width+10, [attributedString size].height)];
    [image unlockFocus];
    
    return image;
}

-(NSImage*)rectagularTokenImage{
    static NSDictionary * _fontAttibutes = nil;
    if (!_fontAttibutes) _fontAttibutes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:11],NSFontAttributeName, nil];
    
    NSAttributedString * attributedString = [[[NSAttributedString alloc] initWithString:self.tokenTitle attributes:_fontAttibutes] autorelease];
    if (!attributedString)  return nil;
    NSSize imgSize =NSMakeSize([attributedString size].width+12, [attributedString size].height+0);
    if (imgSize.width==0 || imgSize.height==0)
        return nil;
    
    NSImage * image = [[[NSImage alloc] initWithSize:imgSize] autorelease];
    [image lockFocus];
    
    NSRect pathRect = NSMakeRect(2,0, [attributedString size].width+8, [attributedString size].height);
    NSBezierPath * path = [NSBezierPath bezierPathWithRect: pathRect];
    
    if (self.selected){
        [[NSColor colorWithCalibratedRed:0.671 green:0.706 blue:0.773 alpha:1.000] set];
    }
    else {
        [[(_MTTokenTextAttachment*)self.attachment color] set];
    }
    
    [path fill];
    
    [[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0]set];
    
    [attributedString drawInRect:NSMakeRect(6, 0, [attributedString size].width+3, [attributedString size].height)];
    [image unlockFocus];
    
    return image;
}

-(NSImage*)roundedColorTokenImage{
    static NSDictionary * _fontAttibutes = nil;
    CGFloat w = 19;
    if (!_fontAttibutes) _fontAttibutes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:11],NSFontAttributeName, nil];
    
    NSAttributedString * attributedString = [[[NSAttributedString alloc] initWithString:self.tokenTitle attributes:_fontAttibutes] autorelease];
    if (!attributedString)  return nil;
    NSSize imgSize =NSMakeSize([attributedString size].width+w+5, [attributedString size].height+0);
    if (imgSize.width == 0 || imgSize.height == 0)
        return nil;
    
    NSImage * image = [[[NSImage alloc] initWithSize:imgSize] autorelease];
    [image lockFocus];
    CGFloat radius = 6;
    
    NSRect pathRect = NSMakeRect(2, 1, [attributedString size].width+w, [attributedString size].height-2);
    
    NSBezierPath * path = [NSBezierPath bezierPath];
    
    CGFloat minimumX	= NSMinX(pathRect) - 0.5; // subtract half values to mitigate anti-aliasing
    CGFloat maximumX	= NSMaxX(pathRect) - 0.25;
    CGFloat minimumY	= NSMinY(pathRect) - 0.5;
    CGFloat maximumY	= NSMaxY(pathRect) - 0.5;
    CGFloat midY		= NSMidY(pathRect);
    CGFloat midX		= NSMidX(pathRect);
    
    // bottom right curve and bottom edge
    [path moveToPoint: NSMakePoint(midX, minimumY)];
    [path appendBezierPathWithArcFromPoint: NSMakePoint(maximumX, minimumY) toPoint: NSMakePoint(maximumX, midY) radius: radius-.5];
    
    // top right curve and right edge
    [path appendBezierPathWithArcFromPoint: NSMakePoint(maximumX, maximumY) toPoint: NSMakePoint(midX, maximumY) radius: radius-.5];
    
    // top left curve and top edge
    [path appendBezierPathWithArcFromPoint: NSMakePoint(minimumX, maximumY) toPoint: NSMakePoint(minimumX, midY) radius: radius];
    
    // bottom left curve and left edge
    [path appendBezierPathWithArcFromPoint: NSMakePoint(minimumX, minimumY) toPoint: NSMakePoint(midX, minimumY) radius: radius];
    [path closePath];
    
    
    [path setLineWidth:1.0];
    if (self.selected)
        [[NSColor colorWithCalibratedRed:0.671 green:0.706 blue:0.773 alpha:1.000] set];
    else {
        [[NSColor colorWithCalibratedRed:0.851 green:0.906 blue:0.973 alpha:1.000] set];
    }
    
    [path fill];
    [[NSColor colorWithCalibratedRed:.588 green:0.749 blue:0.929 alpha:1.000] set];
    [path stroke];
    [[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0]set];
    
    CGFloat circleRadius = NSHeight(pathRect)-3;
    NSRect circleRect = NSMakeRect(NSMinX(pathRect)+1.5 ,NSMinY(pathRect)+1,circleRadius,circleRadius);
    NSBezierPath * colorSwatchPath =[NSBezierPath bezierPathWithOvalInRect:circleRect];
    NSColor * theColor = self.color;
    if (!theColor) theColor = [NSColor whiteColor];
    [self.color set];
    [colorSwatchPath fill];
    [[theColor darkShade] set];
    [colorSwatchPath stroke];
    
    [attributedString drawInRect:NSMakeRect(17, 0, [attributedString size].width+10, [attributedString size].height)];
    [image unlockFocus];
    
    return image;
}

-(NSImage*)roundedLeftSideColorTokenImage{
    static NSDictionary * _fontAttibutes = nil;
    CGFloat w = 19;
    if (!_fontAttibutes) _fontAttibutes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:11],NSFontAttributeName, nil];
    
    NSAttributedString * attributedString = [[[NSAttributedString alloc] initWithString:self.tokenTitle attributes:_fontAttibutes] autorelease];
    if (!attributedString)  return nil;
    NSSize imgSize =NSMakeSize([attributedString size].width+w+5, [attributedString size].height+0);
    if (imgSize.width == 0 || imgSize.height == 0)
        return nil;
    
    NSImage * image = [[[NSImage alloc] initWithSize:imgSize] autorelease];
    [image lockFocus];
    CGFloat radius = 6;
    
    NSRect pathRect = NSMakeRect(2, 1, [attributedString size].width+w, [attributedString size].height-2);
    
    NSBezierPath * path = [NSBezierPath bezierPath];
    
    CGFloat minimumX	= NSMinX(pathRect) - 0.5; // subtract half values to mitigate anti-aliasing
    CGFloat maximumX	= NSMaxX(pathRect) - 0.25;
    CGFloat minimumY	= NSMinY(pathRect) - 0.5;
    CGFloat maximumY	= NSMaxY(pathRect) - 0.5;
    CGFloat midY		= NSMidY(pathRect);
    CGFloat midX		= NSMidX(pathRect);
    
    // bottom right curve and bottom edge
    [path moveToPoint: NSMakePoint(midX, minimumY)];
    [path lineToPoint:NSMakePoint(maximumX, minimumY)];
    
    // top right curve and right edge
    [path lineToPoint:NSMakePoint(maximumX, maximumY)];
    
    // top left curve and top edge
    [path appendBezierPathWithArcFromPoint: NSMakePoint(minimumX, maximumY) toPoint: NSMakePoint(minimumX, midY) radius: radius];
    
    // bottom left curve and left edge
    [path appendBezierPathWithArcFromPoint: NSMakePoint(minimumX, minimumY) toPoint: NSMakePoint(midX, minimumY) radius: radius];
    [path closePath];
    
    
    [path setLineWidth:1.0];
    if (self.selected)
        [[NSColor colorWithCalibratedRed:0.671 green:0.706 blue:0.773 alpha:1.000] set];
    else {
        [[NSColor colorWithCalibratedRed:0.851 green:0.906 blue:0.973 alpha:1.000] set];
    }
    
    [path fill];
    [[NSColor colorWithCalibratedRed:.588 green:0.749 blue:0.929 alpha:1.000] set];
    [path stroke];
    [[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0]set];
    
    CGFloat circleRadius = NSHeight(pathRect)-3;
    NSRect circleRect = NSMakeRect(NSMinX(pathRect)+1.5 ,NSMinY(pathRect)+1,circleRadius,circleRadius);
    NSBezierPath * colorSwatchPath =[NSBezierPath bezierPathWithOvalInRect:circleRect];
    NSColor * theColor = self.color;
    if (!theColor) theColor = [NSColor whiteColor];
    [self.color set];
    [colorSwatchPath fill];
    [[theColor darkShade] set];
    [colorSwatchPath stroke];
    
    [attributedString drawInRect:NSMakeRect(17, 0, [attributedString size].width+10, [attributedString size].height)];
    [image unlockFocus];
    
    return image;
}



-(NSImage *) image{
    switch ([self style]) {
        case kMTTokenStyleRectangular:
            return [self rectagularTokenImage];
        case kMTTokenStyleRoundedColor:
            return [self roundedColorTokenImage];
        case kMTTokenStyleRoundedLeftSideColor:
            return [self roundedLeftSideColorTokenImage];
        default:
            return [self standardTokenImage];
    }
    
}


@end