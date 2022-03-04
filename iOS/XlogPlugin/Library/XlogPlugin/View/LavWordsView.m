//
//  LavWordsView.m
//  XlogPlugin
//
//  Created by Kaoji on 2020/6/15.
//  Copyright © 2020 Kaoji. All rights reserved.
//

#import "LavWordsView.h"

@interface LavWordsView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UIView *lineView;
@property (nonatomic,strong)UIView *bgView;//弹窗主体
@property (nonatomic,strong)UIImageView *closeImageView;//关闭按扭
@property (nonatomic,strong)UITableView *tableView;//日志列表
@property (nonatomic,strong)NSMutableDictionary *logListDict;//数据源
@property (nonatomic,strong)UILabel *noDialogLabel;//数据源
@property(nonatomic,strong)UISegmentedControl *logTypeSegment;//词汇分类
@property(nonatomic,strong)NSArray *currentData;//当前词汇表
@end

@implementation LavWordsView
{
@private XLOG_TYPE _logType;
}

-(instancetype)initWithFrame:(CGRect)frame LogType:(XLOG_TYPE)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _logType = type;
        [self createView];
        [self readDataSource];
    }
    return self;
}

-(void)createView{
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    //红包背景图
        //背景
    _bgView = [self createPopView];
    _bgView.center = self.center;
    [self addSubview:_bgView];
    
    _closeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(_bgView.frame.size.width - 50, 10, 30, 30)];
    NSString *closeImagePath = [XLOG_RES stringByAppendingPathComponent:@"close.png"];
    _closeImageView.image = [UIImage imageWithContentsOfFile:closeImagePath];
    _closeImageView.userInteractionEnabled = YES;
    _closeImageView.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickClose)];
    [_closeImageView addGestureRecognizer:closeTap];
    [_bgView addSubview:_closeImageView];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, _bgView.frame.size.width, _bgView.frame.size.height - 50) style:UITableViewStylePlain];
    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"LOG_LIST"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = UIView.new;
    _tableView.tableFooterView = UIView.new;
    [_bgView addSubview:_tableView];
    
    
    _noDialogLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _bgView.frame.size.height *0.3 , _tableView.frame.size.width, 30)];
    _noDialogLabel.text = @"先设定词汇";
    _noDialogLabel.textAlignment = NSTextAlignmentCenter;
    _noDialogLabel.textColor = [UIColor darkGrayColor];
    [_tableView addSubview:_noDialogLabel];
    
    //只有liteAVSDK需要选
    if (_logType == XLOG_TYPE_IM) {
        return;
    }
    
    CGFloat segW = 120 * (SCREENHEIGHT/667);
    _logTypeSegment = [[UISegmentedControl alloc] initWithItems:@[@"MLVB",@"TRTC"]];
    _logTypeSegment.selectedSegmentIndex = 0;
    _logTypeSegment.tintColor = [UIColor whiteColor];
    _logTypeSegment.backgroundColor = [UIColor colorWithRed:113/255  green:113/255 blue:113/255 alpha:0.4];
    _logTypeSegment.frame = CGRectMake(_bgView.frame.size.width/2 -segW/2, 10, segW, 36);
    [_logTypeSegment addTarget:self action:@selector(segmentValueChange:) forControlEvents:UIControlEventValueChanged];
    [_bgView addSubview:_logTypeSegment];
}

-(void)readDataSource{
    NSString *wordsPlistPath = [XLOG_RES stringByAppendingPathComponent:@"words.plist"];
    _logListDict = [NSMutableDictionary dictionaryWithContentsOfFile:wordsPlistPath];
}


#pragma mark - TableViewDataSource&Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    _currentData = [self getDataSource];
    _noDialogLabel.hidden = _currentData.count? YES:NO;
    return _currentData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LOG_LIST" forIndexPath:indexPath];
    cell.textLabel.text = _currentData[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if(self.wordsCallBack){
        self.wordsCallBack(_currentData[indexPath.row]);
    }
}

-(NSArray *)getDataSource{
    if (_logType == XLOG_TYPE_IM) {
        return _logListDict[@"IM"];
    }
    return _logListDict[_logTypeSegment.selectedSegmentIndex == 0 ?@"MLVB":@"TRTC"];
}

-(void)segmentValueChange:(UISegmentedControl *)sender{
    [self.tableView reloadData];
}

-(void)onClickClose{
    [self hide];
}
@end
