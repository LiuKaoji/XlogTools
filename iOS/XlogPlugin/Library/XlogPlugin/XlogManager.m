//
//  XlogManager.m
//  XlogPlugin
//
//  Created by Kaoji on 2020/4/27.
//  Copyright © 2020 by Kaoji. All rights reserved.
//

#import "XlogManager.h"
#import <Python/Python.h>
#import <ZipArchive/ZipArchive.h>
#import "XLogViewer.h"
#import "XLogFloatBtn.h"
#import "XlogListView.h"

@interface XlogManager ()<SSZipArchiveDelegate>
@end

@implementation XlogManager
{
    @protected PyObject *pyObj;//用于执行脚本
}
/**
* 单例
*/
+ (instancetype)shared{
    
    static XlogManager *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return _sharedSingleton;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [XlogManager shared];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [XlogManager shared];
}

-(void)showFloatButtonInView:(UIView *)parentView{
    XLogFloatBtn * button = [[XLogFloatBtn alloc] initWithFrame:CGRectMake(-5, [UIScreen mainScreen].bounds.size.height/2 , 50, 50) color:[UIColor colorWithRed:135/255.0 green:216/255.0 blue:80/255.0 alpha:1]];
    __weak typeof(self) weakSelf = self;
    button.btnClickCallback = ^{
        XlogListView *listView = [[XlogListView alloc] initWithFrame:UIApplication.sharedApplication.keyWindow.bounds];
        listView.clickCallback = ^(NSString * _Nonnull logFilePath) {
            NSString *outFilePath = [logFilePath stringByAppendingString:@".log"];
            [weakSelf decodeAndPreviewXlogFrom:logFilePath to:outFilePath];
        };
        [listView show];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:button];
}
/**
* 初始化Python环境并加载YDL
*/
- (void)setupWithStatus:(dispatch_block_t)setupCallback{
    
    _setupCallback = setupCallback;
    if([self checkEnv]){
        [self InitPythonAndLoadXlogObject];
    }
}

/**
* 初始化Python环境
*/
- (BOOL)checkEnv{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:ENV_CP_PATH]) {
       [SSZipArchive unzipFileAtPath:ENV_PATH toDestination:DOC_PATH delegate:self];
        return NO;
    }
    return YES;
}

/**
* 加载YDL
*/
- (void)InitPythonAndLoadXlogObject{
    
    //设置Python Home的位置并初始化Python
    NSString *resourcePath = [ENV_CP_PATH stringByAppendingString:@"/Resources"];
    const char * frameworkPath = [[NSString stringWithFormat:@"%@/Resources",ENV_CP_PATH] UTF8String];
    wchar_t  *pythonHome = _Py_char2wchar(frameworkPath, NULL);
    Py_SetPythonHome(pythonHome);
    Py_Initialize();
    PyEval_InitThreads();
    if(Py_IsInitialized() == NO){
        //初始化Python环境失败
        [self setXStatus:XLOG_STATUS_PyError];
        return;
    }
    
    putenv("PYTHONDONTWRITEBYTECODE=1");
    
    NSString *python_path = [NSString stringWithFormat:@"PYTHONPATH=%@/python_scripts:%@/lib/python3.4/site-packages/", resourcePath, resourcePath, nil];
    NSLog(@"PYTHONPATH is: %@", python_path);
    putenv((char *)[python_path UTF8String]);
    
    NSString *checkXLogModulePath = [SCRIPT_PATH stringByAppendingString:[NSString stringWithFormat:@"%@.py",XLOG_DEC_LAV]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:checkXLogModulePath]) {
        //初始化Python环境失败
        [self setXStatus:XLOG_STATUS_LoadError];
        return;
    }
    
    pyObj = PyImport_ImportModule(XLOG_DEC_LAV.UTF8String);
    if (pyObj == NULL)
    {
        [self setXStatus:XLOG_STATUS_LoadError];
        PyErr_Print();
        return;
    }
    [self setXStatus:XLOG_STATUS_OK];
    return;
}

-(void)setXStatus:(XLOG_STATUS)xStatus{
    _xStatus = xStatus;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.setupCallback){
            self.setupCallback();
        }
    });
}

-(void)openDecodedFile:(NSString *)logPath{
    XLogViewer *viewer = [[XLogViewer alloc] init];
    [viewer setXlogItemPath:logPath];
    viewer.modalPresentationStyle = UIModalPresentationFullScreen;
    [[XlogManager findCurrentShowingViewController] presentViewController:viewer animated:YES completion:nil];
}

-(BOOL)decodeXlogFrom:(NSString *)path to:(NSString *)outPath{
    
    PyObject *result = PyObject_CallMethod(self->pyObj, "ParseFile","(s,s)", [path UTF8String],[outPath UTF8String]);
    if (result == NULL) {
          PyErr_Print();
          free(result);
          return NO;
      }
    PyErr_Print();
    [self setXStatus:XLOG_STATUS_LoadError];
    return YES;
}

- (void)decodeAndPreviewXlogFrom:(NSString *)path to:(NSString *)outPath{
    
    //未解码过
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //处理耗时操作的代码块...
        __block BOOL isSuccess;
        if ([self checkDecodeConditions:path to:outPath]) {
            isSuccess =  [self decodeXlogFrom:path to:outPath];
        }
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            XLogViewer *viewer = [[XLogViewer alloc] init];
            [viewer setXlogItemPath:outPath];
            viewer.modalPresentationStyle = UIModalPresentationFullScreen;
            [[XlogManager findCurrentShowingViewController] presentViewController:viewer animated:YES completion:nil];
        });
    });
}

-(BOOL)checkDecodeConditions:(NSString *)path to:(NSString *)outPath{
    //日志不存在 触发解压条件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outPath]) {
        return NO;
    }
    //XLog修改日期大于解压文件的修改日期
    NSError *error = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:&error];
    NSDictionary *outAttributes = [fileManager attributesOfItemAtPath:outPath error:&error];
    NSDate *modDate = [attributes objectForKey:NSFileModificationDate];
    NSDate *outModDate = [outAttributes objectForKey:NSFileModificationDate];
    NSTimeInterval interval = [modDate timeIntervalSince1970];
    NSTimeInterval outInterval = [outModDate timeIntervalSince1970];
    return interval > outInterval ? YES:NO;
}

#pragma -SSZIPARCHIEVE Delegate
#pragma mark - SSZipArchiveDelegate
- (void)zipArchiveWillUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo {
    NSLog(@"将要解压。");
}
 
- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath{
    NSLog(@"解压完成！");
    [self InitPythonAndLoadXlogObject];
}

- (void)zipArchiveProgressEvent:(unsigned long long)loaded total:(unsigned long long)total{
    NSLog(@"解压进度%llu\n 解压总大小%llu",loaded,total);
}

+ (UIViewController *)findCurrentShowingViewController {    //获得当前活动窗口的根视图
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentShowingVC = [XlogManager findCurrentShowingViewControllerFrom:vc];
    return currentShowingVC;
}//注意考虑几种特殊情况：①A present B, B present C，参数vc为A时候的情况/* 完整的描述请参见文件头部 *

+ (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc
{    //方法1：递归方法 Recursive method
    UIViewController *currentShowingVC;    if ([vc presentedViewController]) { //注要优先判断vc是否有弹出其他视图，如有则当前显示的视图肯定是在那上面
        // 当前视图是被presented出来的
        UIViewController *nextRootVC = [vc presentedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {        // 根视图为UITabBarController
        UIViewController *nextRootVC = [(UITabBarController *)vc selectedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else if ([vc isKindOfClass:[UINavigationController class]]){        // 根视图为UINavigationController
        UIViewController *nextRootVC = [(UINavigationController *)vc visibleViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else {        // 根视图为非导航类
        currentShowingVC = vc;
    }
    return currentShowingVC;
}

@end
