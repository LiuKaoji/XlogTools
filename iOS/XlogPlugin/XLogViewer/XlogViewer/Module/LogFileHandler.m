//
//  LogFileHandler.m
//  XlogViewer
//
//  Created by kaoji on 2020/11/23.
//  Copyright © 2020 Damon. All rights reserved.
//

#import "LogFileHandler.h"
#import "MBProgressHUD+JDragon.h"

@implementation LogFileHandler
-(void)didRecievedLogFile:(NSURL *)url{
    
    //文件浏览器 选择了本程序沙盒才会有此情况
    if ([self isThisApp:url]) {
        //直接打开
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REV_XLOG" object:url.path];
        return;
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
    
}

-(BOOL)isThisApp:(NSURL *)url{
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    if ([url.path containsString:docPath]) {
        return  YES;
    }
    return NO;
}

@end
