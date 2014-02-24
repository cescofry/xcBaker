//
//  ZFRColor.h
//  testColor
//
//  Created by Francesco Frison on 11/26/13.
//  Copyright (c) 2013 Francesco Frison. All rights reserved.
//

#import <UIKit/UIKit.h>

#define $(string) [ZFRColors colors][string]

@interface ZFRColors : UIColor

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

+ (ZFRColors *)colors;

@end
