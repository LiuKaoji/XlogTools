//
//  Pop.m
//  XlogPlugin
//
//  Created by Kaoji on 2020/6/26.
//  Copyright © 2020 Kaoji. All rights reserved.
//

#import "UIView + pop.h"

@implementation UIView (pop)
-(UIView *)createPopView{
    //背景
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width * 0.8, UIScreen.mainScreen.bounds.size.height * 0.7)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 16;
    bgView.layer.masksToBounds = YES;
    bgView.userInteractionEnabled = YES;
    return bgView;
}
-(void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    // 将view宽高缩至无限小（点）
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [UIView animateWithDuration:0.2 animations:^{
        // 以动画的形式将view慢慢放大至原始大小的1倍
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            // 以动画的形式将view恢复至原始大小
            self.transform = CGAffineTransformIdentity;
            UIButton *button = [[UIApplication sharedApplication].keyWindow viewWithTag:FloatBtnTag];
            button.hidden = YES;
        }];
    }];
}
-(void)hide
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            UIButton *button = [[UIApplication sharedApplication].keyWindow viewWithTag:FloatBtnTag];
            button.hidden = NO;
        }];
    }];
}
@end
