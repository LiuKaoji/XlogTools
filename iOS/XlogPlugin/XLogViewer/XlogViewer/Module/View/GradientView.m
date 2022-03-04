//
//  GradientView.m
//  Example
//
//  Created by Kaoji on 2020/6/14.
//  Copyright © 2020 Kaoji. All rights reserved.
//

#import "GradientView.h"

@interface GradientView () <CAAnimationDelegate>
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) NSArray<UIColor *> *colors;
@property (nonatomic, assign) int currentGradientIndex;
@end

@implementation GradientView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
        [self doAnimation];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

-(void)didBecomeActive{
    [self doAnimation];//处理一下 不然后台回来 动画停止
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors = [self currentGradient];
        _gradientLayer.startPoint = CGPointMake(0.0, 1.0);
        _gradientLayer.endPoint = CGPointMake(1.0, 0.0);
        _gradientLayer.drawsAsynchronously = YES;
    }
    return _gradientLayer;
}

- (void)doAnimation {
    self.currentGradientIndex += 1;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
    animation.duration = 2.0;
    animation.toValue = [self currentGradient];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    [self.gradientLayer addAnimation:animation forKey:@"ColorChange"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        self.gradientLayer.colors = [self currentGradient];
        [self doAnimation];
    }
}

- (NSArray <UIColor*> *)colors {
    if (!_colors) {
        _colors = @[[UIColor colorWithRed:156 * 1.0/255 green:39 * 1.0/255 blue:176 * 1.0/255 alpha:1.0],
                    [UIColor colorWithRed:255 * 1.0/255 green:64 * 1.0/255 blue:129 * 1.0/255 alpha:1.0],
                    [UIColor colorWithRed:123 * 1.0/255 green:31 * 1.0/255 blue:162 * 1.0/255 alpha:1.0],
                    [UIColor colorWithRed:32 * 1.0/255 green:76 * 1.0/255 blue:255 * 1.0/255 alpha:1.0],
                    [UIColor colorWithRed:32 * 1.0/255 green:158 * 1.0/255 blue:255 * 1.0/255 alpha:1.0],
                    [UIColor colorWithRed:90 * 1.0/255 green:120 * 1.0/255 blue:127 * 1.0/255 alpha:1.0],
                    [UIColor colorWithRed:58 * 1.0/255 green:255 * 1.0/255 blue:217 * 1.0/255 alpha:1.0]];
    }
    return _colors;
}

- (NSArray *)currentGradient {
    return @[(id)self.colors[self.currentGradientIndex % self.colors.count].CGColor, (id)self.colors[(self.currentGradientIndex + 1) % self.colors.count].CGColor];
}

- (void)layoutSubviews{
    self.gradientLayer.frame = self.bounds;
}

@end
