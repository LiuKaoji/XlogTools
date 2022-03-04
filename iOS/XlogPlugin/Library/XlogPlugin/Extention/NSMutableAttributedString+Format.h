//
//  NSMutableAttributedString+Format.h
//  XlogPlugin
//
//  Created by kaoji on 2020/5/6.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (Format)
-(void)applyAtt:(NSDictionary *)att forSubString:(NSString *)subStr;
-(void)applyAtt:(NSDictionary *)att forRange:(NSRange)range;
-(void)applyColor:(UIColor *)color forSubString:(NSString *)subStr;
-(void)applyColor:(UIColor *)color forRange:(NSRange)range;
-(void)applyFont:(UIFont *)font forRange:(NSRange)range;
- (NSMutableArray*)calculateSubStringCount:(NSString *)str str:(NSString *)matchStr;
@end

NS_ASSUME_NONNULL_END
