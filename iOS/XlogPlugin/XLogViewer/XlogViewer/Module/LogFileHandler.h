//
//  LogFileHandler.h
//  XlogViewer
//
//  Created by kaoji on 2020/11/23.
//  Copyright © 2020 Damon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogFileHandler : NSObject

///其他程序直接通过Airdrop面板 选择此程序打开
-(void)didRecievedLogFile:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
