//
//  MainView.m
//  Example
//
//  Created by Kaoji on 2020/6/20.
//  Copyright © 2020 Kaoji. All rights reserved.
//

#import "MainView.h"
#import "Masonry.h"
#import "MBProgressHUD+JDragon.h"
#import "GradientView.h"
#import <XlogPlugin/XLogPlugin-prefix.pch>

@interface MainView ()
@property(nonatomic,strong)UIView *lineView;
@property(nonatomic,strong)UISegmentedControl *logTypeSegment;
@property(nonatomic,strong)UIButton *githubBtn;
@property(nonatomic,strong)UILabel *versionLabel;
@end

@implementation MainView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
    }
    return self;
}

-(void)createView{
    
    GradientView *backgroudAnimationView =  [[GradientView alloc] initWithFrame:self.frame];
    [self addSubview:backgroudAnimationView];
    [self setTitleArr:@[@"创建日志",@"日志列表",@"文件查看"] Images:@[@"create",@"logList",@"disk"]];
    
    _githubBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 45, STATUS_BAR_HEIGHT + 10, 30, 30)];
    [_githubBtn setImage:[UIImage imageNamed:@"github"] forState:UIControlStateNormal];
    [_githubBtn addTarget:self action:@selector(onClickGithub) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_githubBtn];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - (isBangsDevice ?42:38), SCREENWIDTH, 30)];
    _versionLabel.text = [NSString localizedStringWithFormat:@"XlogViewer V%@",version];
    _versionLabel.font = [UIFont systemFontOfSize:12];
    _versionLabel.textAlignment = NSTextAlignmentCenter;
    _versionLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:_versionLabel];
}

- (void)setTitleArr:(NSArray *)titleArr Images:(NSArray *)imagesArr
{
    UIView *stackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width *0.4, UIScreen.mainScreen.bounds.size.height *0.7)];
    stackView.center = self.center;
    [self addSubview:stackView];
    
    NSMutableArray *arrayMut = [NSMutableArray array];
    
    for (int i = 0; i<titleArr.count; i++) {
        
        UIView *containView = [UIView new];
        containView.tag = OptionTag + i;
        [containView setBackgroundColor:[UIColor colorWithRed:113/255  green:113/255 blue:113/255 alpha:0.4]];
        [stackView addSubview:containView];
        [arrayMut addObject:containView];
        
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickBtn:)];
        [containView addGestureRecognizer:tapG];
        
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setImage:[UIImage imageNamed:imagesArr[i]]];
        [containView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:11];
        label.text = titleArr[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        [containView addSubview:label];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(stackView.frame.size.width * 0.35));
            make.centerX.equalTo(containView);
            make.centerY.equalTo(containView).offset(-8 - label.font.pointSize);
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(containView);
            make.height.equalTo(@(label.font.pointSize));
            make.centerX.equalTo(containView);
            make.top.equalTo(imageView.mas_bottom).offset(18);
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            containView.layer.cornerRadius = 10;
        });
    }
    
    if (arrayMut.count <= 0) {
        return;
    }
    
    [arrayMut mas_distributeViewsAlongAxis:MASAxisTypeVertical
                          withFixedSpacing:20   //item间距
                               leadSpacing:0   //起始间距
                               tailSpacing:0]; //结尾间距
    [arrayMut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(stackView.mas_centerX);
        make.width.equalTo(stackView.mas_width);
    }];
}

-(void)onClickBtn:(UITapGestureRecognizer *)sender{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onClickOption:)]){
        [self.delegate onClickOption:sender.view.tag - OptionTag];
    }
}

-(void)onClickGithub{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/LiuKaoji/XlogViewer"] options:@{} completionHandler:nil];
}

@end
