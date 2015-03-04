//
//  NSColor+Shades.m
//  TokenField
//
//  Created by smorr on 2015-03-04.
//
//

#import "NSColor+Shades.h"
#import <objc/runtime.h>

@implementation NSColor (Shades)

-(NSColor*)paleShade{
    NSColor * paleColor = objc_getAssociatedObject(self,sel_registerName("ca.indev.ColorPaleShade"));
    if (!paleColor) {
        
        NSColor * convertedColor = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
        if (!convertedColor){
            convertedColor = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        }
        CGFloat hue,saturation,brightness,alpha;
        CGFloat red,blue,green;
        
        [convertedColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [convertedColor getRed:&red green: &green blue: &blue alpha: nil];
        
        // luma luminosity factor is based on the conversion of RGB to NTSC monochrome to get the a rough value of luminosity for a color
        // I then inverse and slide it to get a factor to multiple the saturation by
        CGFloat luma  = 1.35-(red*.3+green*.5+blue*.2);
        
        paleColor= [NSColor colorWithCalibratedHue:hue saturation:(saturation*.4*luma) brightness:brightness+(1-brightness)*.67 alpha:alpha];
        objc_setAssociatedObject(self,sel_registerName("ca.indev.ColorPaleShade"),paleColor,OBJC_ASSOCIATION_RETAIN);
    }
    
    return paleColor;
    
}

-(NSColor*)darkShade{
    NSColor * darkColor = objc_getAssociatedObject(self,sel_registerName("ca.indev.ColorDarkShade"));
    if (!darkColor) {
        
        NSColor * convertedColor = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
        if (!convertedColor){
            convertedColor = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        }
        CGFloat hue,saturation,brightness,alpha;
        CGFloat red,blue,green;
        
        [convertedColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [convertedColor getRed:&red green: &green blue: &blue alpha: nil];
        
        // luma luminosity factor is based on the conversion of RGB to NTSC monochrome to get the a rough value of luminosity for a color
        // I then inverse and slide it to get a factor to multiple the saturation by
        CGFloat luma  = 1.35-(red*.3+green*.5+blue*.2);
        
        darkColor= [NSColor colorWithCalibratedHue:hue saturation:(saturation*1.2*luma) brightness:MAX(0,brightness*.67) alpha:alpha];
        
        
        objc_setAssociatedObject(self,sel_registerName("ca.indev.ColorDarkShade"),darkColor,OBJC_ASSOCIATION_RETAIN);
    }
    
    return darkColor;
    
}
@end
