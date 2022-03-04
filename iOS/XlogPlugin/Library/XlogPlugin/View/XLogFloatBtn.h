//
//  SuspensionButtonCopy.h
//  XlogPlugin
//
//  Created by Kaoji on 2020/5/7.
//  Copyright © 2020 Kaoji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface XLogFloatBtn : UIButton
@property (nonatomic,copy) dispatch_block_t btnClickCallback;
@property (nonatomic,strong)UIColor * normalColor;
- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color;

@end

NS_ASSUME_NONNULL_END
