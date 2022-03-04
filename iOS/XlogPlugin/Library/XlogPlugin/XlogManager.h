//
//  XlogManager.h
//  XlogPlugin
//
//  Created by Kaoji on 2020/4/27.
//  Copyright © 2020 by Kaoji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XLOG_STATUS) {
    XLOG_STATUS_STOP = 0,//未初始化
    XLOG_STATUS_OK = 1,//python已经加载 并且xlog解码模块已加载
    XLOG_STATUS_unzipError = 2,//解压资源失败
    XLOG_STATUS_PyError = 3,//python初始化失败
    XLOG_STATUS_LoadError = 4,//xlog解码模块加载失败
    XLOG_STATUS_DecodedError = 5,//解码失败
};

typedef NS_ENUM(NSUInteger, XLOG_TYPE) {
    XLOG_TYPE_LAV = 0,//log类型LiteAVSDK
    XLOG_TYPE_IM = 1,//log类型IMSDK
};

typedef NS_ENUM(NSUInteger, LOG_TYPE) {
    LOG_TYPE_XLOG = 0,//未解压的Log
    LOG_TYPE_LOG = 1,//经过解压的xlog
};


@interface XlogManager : NSObject
@property (nonatomic,copy)dispatch_block_t setupCallback;
@property(nonatomic,assign) XLOG_STATUS xStatus;
+ (instancetype)shared;

//初始化
- (void)setupWithStatus:(dispatch_block_t)setupCallback;

//全局显示按钮
-(void)showFloatButton;

//将唤醒日志按钮添加到视图
-(void)showFloatButtonInView:(UIView *)parentView;

//打开已经解密的文件
-(void)openDecodedFile:(NSString *)logPath;

//解码Xlog
-(BOOL)decodeXlogFrom:(NSString *)path to:(NSString *)outPath;

//解码并且使用内置预览
-(void)decodeAndPreviewXlogFrom:(NSString *)path to:(NSString *)outPath;

@end

NS_ASSUME_NONNULL_END
