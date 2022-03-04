/**
*                                         ,s555SB@@&
*                                      :9H####@@@@@Xi
*                                     1@@@@@@@@@@@@@@8
*                                   ,8@@@@@@@@@B@@@@@@8
*                                  :B@@@@X3hi8Bs;B@@@@@Ah,
*             ,8i                  r@@@B:     1S ,M@@@@@@#8;
*            1AB35.i:               X@@8 .   SGhr ,A@@@@@@@@S
*            1@h31MX8                18Hhh3i .i3r ,A@@@@@@@@@5
*            ;@&i,58r5                 rGSS:     :B@@@@@@@@@@A
*             1#i  . 9i                 hX.  .: .5@@@@@@@@@@@1
*              sG1,  ,G53s.              9#Xi;hS5 3B@@@@@@@B1
*               .h8h.,A@@@MXSs,           #@H1:    3ssSSX@1
*               s ,@@@@@@@@@@@@Xhi,       r#@@X1s9M8    .GA981
*               ,. rS8H#@@@@@@@@@@#HG51;.  .h31i;9@r    .8@@@@BS;i;
*                .19AXXXAB@@@@@@@@@@@@@@#MHXG893hrX#XGGXM@@@@@@@@@@MS
*                s@@MM@@@hsX#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&,
*              :GB@#3G@@Brs ,1GM@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@B,
*            .hM@@@#@@#MX 51  r;iSGAM@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8
*          :3B@@@@@@@@@@@&9@h :Gs   .;sSXH@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:
*      s&HA#@@@@@@@@@@@@@@M89A;.8S.       ,r3@@@@@@@@@@@@@@@@@@@@@@@@@@@r
*   ,13B@@@@@@@@@@@@@@@@@@@5 5B3 ;.         ;@@@@@@@@@@@@@@@@@@@@@@@@@@@i
*  5#@@#&@@@@@@@@@@@@@@@@@@9  .39:          ;@@@@@@@@@@@@@@@@@@@@@@@@@@@;
*  9@@@X:MM@@@@@@@@@@@@@@@#;    ;31.         H@@@@@@@@@@@@@@@@@@@@@@@@@@:
*   SH#@B9.rM@@@@@@@@@@@@@B       :.         3@@@@@@@@@@@@@@@@@@@@@@@@@@5
*     ,:.   9@@@@@@@@@@@#HB5                 .M@@@@@@@@@@@@@@@@@@@@@@@@@B
*           ,ssirhSM@&1;i19911i,.             s@@@@@@@@@@@@@@@@@@@@@@@@@@S
*              ,,,rHAri1h1rh&@#353Sh:          8@@@@@@@@@@@@@@@@@@@@@@@@@#:
*            .A3hH@#5S553&@@#h   i:i9S          #@@@@@@@@@@@@@@@@@@@@@@@@@A.
*
*
*  
*/

#import "AppDelegate.h"
#import "MainViewController.h"
#import <XlogPlugin/XlogPlugin.h>
#import "MBProgressHUD+JDragon.h"


@interface AppDelegate ()
@property(nonatomic,strong)MainViewController *mainVC;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _mainVC = [MainViewController new];
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_window setRootViewController:[[UINavigationController alloc]initWithRootViewController:_mainVC]];
    [_window makeKeyAndVisible];
    [self checkLogPath];
    [self setupXlogPlugin];
    sleep(1.0);
    return YES;
}

-(void)checkLogPath{
    
    //获取Document文件
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * rarFilePath = [docsdir stringByAppendingPathComponent:@"log"];//将需要创建的串拼接到后面
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if (![fileManager fileExistsAtPath:rarFilePath isDirectory:&isDir]) {//如果文件夹不存在
        [fileManager createDirectoryAtPath:rarFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    //从其他App接收Xlog文件 同名覆盖原则
    if(![url.pathExtension isEqualToString:@"xlog"]&&![url.pathExtension isEqualToString:@"log"]){
        [MBProgressHUD showSuccessMessage:@"不支持的文件类型"];
        return false;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    if (url != nil) {
        NSString *path = [[url path] stringByRemovingPercentEncoding];
   
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",@"/log/",url.lastPathComponent]];
        NSString *exactedPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",@"/log/",url.lastPathComponent]];
        if ([fileManager fileExistsAtPath:filePath]) {
            [fileManager removeItemAtPath:filePath error:nil];//已存在文件,删除再拷贝
            [fileManager removeItemAtPath:exactedPath error:nil];//已存在文件,所以曾经解压过的删一次
        }
        
        BOOL isSuccess = [fileManager copyItemAtPath:path toPath:filePath error:nil];
        if (isSuccess == YES) {
            NSLog(@"拷贝成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"REV_XLOG" object:filePath];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"REV_XLOG_ERROR" object:nil];
        }
    }
    //如果不删除会在Documents Inbox下面残留
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    NSLog(@"application:openURL:options:");
    return  YES;
}


-(void)setupXlogPlugin{
    [[XlogManager shared] setupWithStatus:^{
        NSLog(@"XlogPlugin初始化:%@",[XlogManager shared].xStatus == XLOG_STATUS_OK ?@"成功":@"失败");
        
        __weak typeof(self) weakSelf = self;
        if([XlogManager shared].xStatus == XLOG_STATUS_OK){
            [[XlogManager shared] showFloatButtonInView:weakSelf.mainVC.view];
        }else if (XlogManager.shared.xStatus == XLOG_STATUS_DecodedError){
            [MBProgressHUD showErrorMessage:[NSString stringWithFormat:@"解码失败(%zd)",[XlogManager shared].xStatus]];
        }
        else{
            [MBProgressHUD showErrorMessage:[NSString stringWithFormat:@"发生错误(%zd)",[XlogManager shared].xStatus]];
        }
    }];
}

@end
