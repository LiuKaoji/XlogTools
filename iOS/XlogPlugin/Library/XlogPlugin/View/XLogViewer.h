//
//  XLogViewer.h
//  XlogPlugin
//
//  Created by kaoji on 2020/5/6.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface XLogViewer : UIViewController<UISearchBarDelegate>
-(void)setXlogItemPath:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
