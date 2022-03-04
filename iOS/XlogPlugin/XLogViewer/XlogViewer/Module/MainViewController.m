//
//  ViewController.m
//  Example
//
//  Created by Kaoji on 2020/4/28.
//  Copyright © 2020 Kaoji. All rights reserved.
//

#import "MainViewController.h"
#import <XlogPlugin/XlogPlugin.h>
#import "SandBoxPreviewTool.h"
#import "MBProgressHUD+JDragon.h"
#import "MainView.h"
#import <AVKit/AVKit.h>

@interface MainViewController ()<MainViewDelegate>
@property(nonatomic,strong)MainView *mainView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRevXlogFile:) name:@"REV_XLOG" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCase) name:@"REV_XLOG_ERROR" object:nil];
}

-(void)setupUI{
    _mainView = [[MainView alloc] initWithFrame:self.view.frame];
    _mainView.delegate = self;
    [self.view addSubview:_mainView];
}

-(void)onClickOption:(NSInteger)tag{
    //创建日志
       if(tag == 0){
           [self checkFolderAndCopyLog];
       }else if(tag == 1){
       //显示日志列表
           XlogListView *listView = [[XlogListView alloc] initWithFrame:UIApplication.sharedApplication.keyWindow.bounds];
           [listView show];
       }else{
           //沙盒查看
           [[SandBoxPreviewTool sharedTool] autoOpenCloseApplicationDiskDirectoryPanel];
       }

}

//检查日志目录
-(void)checkFolderAndCopyLog{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:kPathLog]){//如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        NSLog(@"first run");
        [fileManager createDirectoryAtPath:kPathLog withIntermediateDirectories:YES attributes:nil error:nil];
        [self copyLog];
    }else{
        [self copyLog];
    }
}

//拷贝测试日志到沙盒
-(void)copyLog{
   NSString *testLogPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"xlog"];
    NSString *copyPath = [kPathLog stringByAppendingPathComponent:testLogPath.lastPathComponent];
    if(![[NSFileManager defaultManager]fileExistsAtPath:copyPath]){
        [[NSFileManager defaultManager] copyItemAtPath:testLogPath toPath:copyPath error:nil];
         //[MBProgressHUD showInfoMessage:@"文件已拷贝"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REV_XLOG" object:copyPath];
    }else{
        [MBProgressHUD showInfoMessage:@"文件已存在"];
    }
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

-(void)didRevXlogFile:(NSNotification *)notify{
    NSString *filePath = notify.object;
    
     //已经解压过
    if([filePath.pathExtension isEqualToString:@".log"]){
        [[XlogManager shared] openDecodedFile:filePath];
        
    }else{
        NSString *outFilePath = [filePath stringByAppendingString:@".log"];
        [[XlogManager shared] decodeAndPreviewXlogFrom:filePath to:outFilePath];
    }
}

-(void)showCase{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"发生错误" message:@"拷贝失败" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"查看解决办法" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self toPlayCaseVideo];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)toPlayCaseVideo{
    
    NSString *caseVideoPath = [[NSBundle mainBundle] pathForResource:@"case" ofType:@"mp4"];
    AVPlayerViewController *player = [[AVPlayerViewController alloc]init];
    player.player = [[AVPlayer alloc]initWithURL:[NSURL fileURLWithPath:caseVideoPath]];
    [player.player play];
    //如果可以播放就跳进去 否则提示一下
    [self presentViewController:player animated:YES completion:^{
        
    }];
}

@end
