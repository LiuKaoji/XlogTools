//
//  NSMutableAttributedString+Format.m
//  XlogPlugin
//
//  Created by kaoji on 2020/5/6.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "NSMutableAttributedString+Format.h"


@implementation NSMutableAttributedString (Format)

-(void)applyAtt:(NSDictionary *)att forSubString:(NSString *)subStr{
    
    NSRange range = [self.string rangeOfString:subStr];
    if(range.location != NSNotFound){
        [self  applyAtt:att forRange:range];
    }
    
}

-(void)applyAtt:(NSDictionary *)att forRange:(NSRange)range{
    
    if(range.location != NSNotFound){
        [self setAttributes:att range:range];
    }
}

-(void)applyColor:(UIColor *)color forSubString:(NSString *)subStr{
    
    NSRange range = [self.string rangeOfString:subStr];
    if(range.location != NSNotFound){
        [self  applyColor:color forRange:range];
    }
}

-(void)applyColor:(UIColor *)color forRange:(NSRange)range{
    
    if(range.location != NSNotFound){
        [self  setAttributes:@{NSForegroundColorAttributeName:color} range:range];
    }
}

-(void)applyFont:(UIFont *)font forRange:(NSRange)range{
    
    if(range.location != NSNotFound){
        [self  setAttributes:@{NSFontAttributeName:font} range:range];
    }
}

//利用朴素算法进行字符串匹配
- (NSMutableArray*)calculateSubStringCount:(NSString *)str str:(NSString *)matchStr {
     //在str中搜索matchStr并返回matchStr下标
        NSInteger matchStrLehgth = matchStr.length;
        NSInteger strLength      = str.length;
        NSMutableArray *indexArray = [[NSMutableArray alloc]init];
        for (int index = 0; index <= (strLength - matchStrLehgth); index ++) {
            NSRange range = {index,matchStr.length};
            if ([matchStr isEqualToString:[str substringWithRange:range]]) {
                [indexArray addObject:[NSString stringWithFormat:@"%d",index]];
            }
        }
        return [NSMutableArray arrayWithArray:indexArray];
}


@end
