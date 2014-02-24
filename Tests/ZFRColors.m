//
//  ZFRColor.m
//  testColor
//
//  Created by Francesco Frison on 11/26/13.
//  Copyright (c) 2013 Francesco Frison. All rights reserved.
//

#import "ZFRColors.h"

@interface ZFRColors ()

@property (nonatomic, strong) NSMutableDictionary *colors;

@end

@implementation ZFRColors

- (NSMutableDictionary *)colors {
    if (!_colors) {
        _colors = [NSMutableDictionary dictionary];
    }
    return _colors;
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key {
    return [self.colors objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    
    UIColor *color = [self _colorFromHEX:obj];
    if (color) {
        [self.colors setObject:color forKey:key];
    }
    
}

- (UIColor *)_colorFromHEX:(NSString *)hex {
    unsigned int value = 0;
    if ([hex hasPrefix:@"#"]) hex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([[NSScanner scannerWithString:hex] scanHexInt:&value])
    {
        if (hex.length == 6)
        {
            // 6 digit hex (#FFFFFF)
            return [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16)) / 255.0
                                   green:((float)((value & 0x00FF00) >> 8)) / 255.0
                                    blue:((float)(value & 0x0000FF)) / 255.0
                                   alpha:1.0];
        }
        else if (hex.length == 3)
        {
            // 3 digit hex (#FFF)
            return [UIColor colorWithRed:((float)((value & 0xF00) >> 8)) / 15.0
                                   green:((float)((value & 0x0F0) >> 4)) / 15.0
                                    blue:((float)(value & 0x00F)) / 15.0
                                   alpha:1.0];
        }
    }
    
    return nil;
}


#pragma mark --
#pragma mark Singleton related Methods

static ZFRColors *sharedObject = nil;
static bool _isLoadingThroughSingleton = NO;

- (id)init
{
    NSAssert(_isLoadingThroughSingleton, @"This should load through +colors");
    self = [super init];
    if (self) {
        
    }
    return self;
}


+ (ZFRColors *)colors {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _isLoadingThroughSingleton = YES;
        sharedObject = [[ZFRColors alloc] init];
    });
    
    return sharedObject;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedObject == nil) {
            sharedObject = [super allocWithZone:zone];
            return sharedObject;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}



@end
