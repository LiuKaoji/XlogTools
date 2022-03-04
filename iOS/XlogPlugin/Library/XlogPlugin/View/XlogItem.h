//
//  XlogItem.h
//  XlogPlugin
//
//  Created by Damon on 2020/7/19.
//  Copyright © 2020 Damon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XlogManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface XlogItem : NSObject
//文件属性
@property (nonatomic,copy)   NSString *fileName;
@property (nonatomic,copy)   NSString *realPath;
@property (nonatomic,copy)   NSString *createDate;
@property (nonatomic,copy)   NSString *motifyDate;
@property (nonatomic,copy)   NSString *fileSize;
@property (nonatomic,assign) NSTimeInterval createtimeInterval;
@property (nonatomic,assign) LOG_TYPE type;

-(void)configWithAttribute:(NSDictionary *)attribute Path:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
