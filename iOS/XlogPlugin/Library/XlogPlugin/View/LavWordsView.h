//
//  LavWordsView.h
//  XlogPlugin
//
//  Created by Kaoji on 2020/6/15.
//  Copyright © 2020 Kaoji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XlogManager.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^WordsBlock)(NSString *searchWord);
@interface LavWordsView : UIView
@property (nonatomic,copy)WordsBlock wordsCallBack;
-(instancetype)initWithFrame:(CGRect)frame LogType:(XLOG_TYPE)type;
@end

NS_ASSUME_NONNULL_END
