//
//  XlogListView.m
//  XlogPlugin
//
//  Created by Kaoji on 2020/5/6.
//  Copyright © 2020 Kaoji. All rights reserved.
//

#import "XlogListView.h"
#import "XlogManager.h"
#import "XLogFloatBtn.h"
#import "XlogItem.h"
#import "XlogListCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SVSegmentedControl.h"

@interface XlogListView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UIView *lineView;
@property (nonatomic,strong)UIImageView *bgView;//弹窗主体
@property (nonatomic,strong)UIImageView *closeImageView;//关闭按扭
@property (nonatomic,strong)UITableView *tableView;//日志列表
@property (nonatomic,strong)NSMutableArray *xlogListArray;//数据源
@property (nonatomic,strong)NSMutableArray *logListArray;//数据源
@property (nonatomic,strong)NSMutableArray *listArray;//数据源
@property (nonatomic,strong)UILabel *noDialogLabel;//数据源
@property (nonatomic,strong)SVSegmentedControl *logSegment;//词汇分类
@end

@implementation XlogListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _xlogListArray = [NSMutableArray array];
        _logListArray  = [NSMutableArray array];
        _listArray  = [NSMutableArray array];
        [self createView];
         [self readDataSource];
    }
    return self;
}

-(void)createView{
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    //背景
    _bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width * 0.8, UIScreen.mainScreen.bounds.size.height * 0.7)];
    _bgView.userInteractionEnabled = YES;
    _bgView.center = self.center;
    _bgView.layer.cornerRadius = 10;
//    NSString *popPath = [XLOG_RES stringByAppendingPathComponent:@"pop.png"];
//    _bgView.image =  [UIImage imageWithContentsOfFile:popPath];
    _bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    [self addSubview:_bgView];
    
    _closeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(_bgView.frame.size.width/2 - 30, _bgView.frame.size.height - 50, 60, 40)];
    NSString *closeImagePath = [XLOG_RES stringByAppendingPathComponent:@"close.png"];
    _closeImageView.image = [UIImage imageWithContentsOfFile:closeImagePath];
    _closeImageView.userInteractionEnabled = YES;
    _closeImageView.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickClose)];
    [_closeImageView addGestureRecognizer:closeTap];
    [_bgView addSubview:_closeImageView];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, _bgView.frame.size.width, _bgView.frame.size.height - 100) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = UIView.new;
    _tableView.tableFooterView = UIView.new;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[XlogListCell class] forCellReuseIdentifier:@"XLOG_LIST_CELL"];
    [_bgView addSubview:_tableView];
    
    
    _noDialogLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _bgView.frame.size.height *0.3 , _tableView.frame.size.width, 30)];
    _noDialogLabel.text = @"没有日志";
    _noDialogLabel.textAlignment = NSTextAlignmentCenter;
    _noDialogLabel.textColor = [UIColor darkGrayColor];
    [_tableView addSubview:_noDialogLabel];
    
    CGFloat segW = 120 * (SCREENHEIGHT/667);
    _logSegment = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Xlog",@"Log", nil]];
    _logSegment.frame = CGRectMake(_bgView.frame.size.width/2 -segW/2, 10, segW, 36);
    [_logSegment addTarget:self action:@selector(logChange:) forControlEvents:UIControlEventValueChanged];
    _logSegment.crossFadeLabelsOnDrag = YES;
    _logSegment.thumb.tintColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.2 alpha:1];
    [_logSegment setSelectedSegmentIndex:0 animated:NO];
    [_bgView addSubview:_logSegment];
}

-(void)readDataSource{
    
    //获取沙盒 Document
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //获取日志路径
    NSString *logPath =  [docPath stringByAppendingFormat:@"/log/"];
    NSMutableArray *fileNames = [NSMutableArray arrayWithArray:[NSFileManager.defaultManager contentsOfDirectoryAtPath:logPath error:nil]];
    for (NSString *oneFile in fileNames) {
        NSString *filePath = [logPath stringByAppendingString:oneFile];
        NSDictionary *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:filePath error:nil];
        
        XlogItem *item = [XlogItem new];
        [item configWithAttribute:attributes Path:filePath];
        
        item.type == LOG_TYPE_XLOG? ([_xlogListArray addObject:item]) :([_logListArray addObject:item]);
    }
    
    //排序
     NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"createtimeInterval" ascending:YES];
    
    NSArray *xSortResult = [_xlogListArray sortedArrayUsingDescriptors:@[sortDesc]];
    [_xlogListArray removeAllObjects];
    [_xlogListArray addObjectsFromArray:xSortResult];
    
    NSArray *sortResult = [_logListArray sortedArrayUsingDescriptors:@[sortDesc]];
    [_logListArray removeAllObjects];
    [_logListArray addObjectsFromArray:sortResult];
    
     BOOL isXlog = (_logSegment.selectedSegmentIndex == 0) ?YES:NO;
     [_listArray addObjectsFromArray:(isXlog? _xlogListArray:_logListArray)];
    
    _noDialogLabel.hidden = _listArray.count? YES:NO;
    
    [self.tableView reloadData];
}

-(void)logChange:(UISegmentedControl *)sender{
    [_listArray removeAllObjects];
    BOOL isXlog = (_logSegment.selectedSegmentIndex == 0) ?YES:NO;
    [_listArray addObjectsFromArray:(isXlog? _xlogListArray:_logListArray)];
    [self.tableView reloadData];
    
    _noDialogLabel.hidden = _listArray.count? YES:NO;
}

-(void)toShareFile:(NSString *)filePath{
    
   NSURL *urlToShare = [NSURL fileURLWithPath:filePath];
    if (!urlToShare) return;
    NSArray *activityItems = @[urlToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [[self currentNC] presentViewController:activityVC animated:YES completion:nil];
}

- (UINavigationController *)currentNC
{
    if (![[UIApplication sharedApplication].windows.lastObject isKindOfClass:[UIWindow class]]) {
        NSAssert(0, @"未获取到导航控制器");
        return nil;
    }
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self getCurrentNCFrom:rootViewController];
}

- (UINavigationController *)getCurrentNCFrom:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UINavigationController *nc = ((UITabBarController *)vc).selectedViewController;
        return [self getCurrentNCFrom:nc];
    }
    else if ([vc isKindOfClass:[UINavigationController class]]) {
        if (((UINavigationController *)vc).presentedViewController) {
            return [self getCurrentNCFrom:((UINavigationController *)vc).presentedViewController];
        }
        return [self getCurrentNCFrom:((UINavigationController *)vc).topViewController];
    }
    else if ([vc isKindOfClass:[UIViewController class]]) {
        if (vc.presentedViewController) {
            return [self getCurrentNCFrom:vc.presentedViewController];
        }
        else {
            return vc.navigationController;
        }
    }
    else {
        NSAssert(0, @"未获取到导航控制器");
        return nil;
    }
}

#pragma mark - TableViewDataSource&Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XlogListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XLOG_LIST_CELL" forIndexPath:indexPath];
    
    XlogItem *item = _listArray[indexPath.row];
    [cell configWithItem:item];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    XlogItem *item = self.listArray[indexPath.row];
    
    //目标日志文件
    NSString *logFilePath = item.realPath;
    if(item.type == LOG_TYPE_XLOG){
        NSString *outFilePath = [logFilePath stringByAppendingString:@".log"];
        [[XlogManager shared] decodeAndPreviewXlogFrom:logFilePath to:outFilePath];
    }else{
        [[XlogManager shared] openDecodedFile:item.realPath];
    }
    
    [self hide];

}

// 返回一个菜单数组
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray  *actionArray = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    // 添加删除操作
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

         XlogItem *item = weakSelf.listArray[indexPath.row];
           [[NSFileManager defaultManager] removeItemAtPath:item.realPath error:nil];
           [weakSelf.listArray removeObject:item];
           if (item.type == LOG_TYPE_XLOG) {
               [weakSelf.xlogListArray removeObject:item];
              
           }else{
               [weakSelf.logListArray removeObject:item];
           }
           //删除Cell
           [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
           weakSelf.noDialogLabel.hidden = weakSelf.listArray.count? YES:NO;
    }];
    
    // 添加删除操作
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"导出" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        XlogItem *item = weakSelf.listArray[indexPath.row];
        [weakSelf toShareFile:item.realPath];
        
    }];
    // 自定义这个菜单的背景色
    editRowAction.backgroundColor = [UIColor lightGrayColor];
    
    [actionArray addObject:deleteRowAction];
    [actionArray addObject:editRowAction];
    
    
    return actionArray;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(void)onClickClose{
    [self hide];
}

@end
