//
//  XlogListCell.m
//  XlogPlugin
//
//  Created by Damon on 2020/7/19.
//  Copyright © 2020 Damon. All rights reserved.
//

#import "XlogListCell.h"

@interface XlogListCell ()
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *subLabel;
@property(nonatomic,strong)UIButton *shareBtn;
@end

@implementation XlogListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super  initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self createUI];
    }
    return  self;
}

-(void)createUI{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.frame.size.width -60, 34)];
    _titleLabel.font = [UIFont systemFontOfSize:12];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self addSubview:_titleLabel];
    
    _subLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_titleLabel.frame), self.frame.size.width -30, 20)];
    _subLabel.font = [UIFont systemFontOfSize:10];
    _subLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self addSubview:_subLabel];
    
}

-(void)configWithItem:(XlogItem *)item{
    _titleLabel.text = item.fileName;
    _subLabel.text = item.createDate;
}

- (void)drawRect:(CGRect)rect {

    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    CGContextFillRect(context, rect);
    
    //上分割线，
    
    //CGContextSetStrokeColorWithColor(context, COLORWHITE.CGColor);
    
    //CGContextStrokeRect(context, CGRectMake(5, -1, rect.size.width - 10, 1));
    
    //下分割线
    
    //设置分割线的颜色
    
    CGContextSetStrokeColorWithColor(context,[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor);
    
    //设置分割线的位置,给1的粗
    
    CGContextStrokeRect(context,CGRectMake(15, rect.size.height-0.5, rect.size.width,0.5));

}
@end
