//
//  XlogListView.h
//  XlogPlugin
//
//  Created by Kaoji on 2020/5/6.
//  Copyright © 2020 Kaoji. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^LogClickBlock)(NSString *logFilePath);
@interface XlogListView : UIView
@property(nonatomic,copy)LogClickBlock clickCallback;
@end

NS_ASSUME_NONNULL_END
