//
//  XlogListCell.h
//  XlogPlugin
//
//  Created by Damon on 2020/7/19.
//  Copyright © 2020 Damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XlogItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface XlogListCell : UITableViewCell
-(void)configWithItem:(XlogItem *)item;
@end

NS_ASSUME_NONNULL_END
