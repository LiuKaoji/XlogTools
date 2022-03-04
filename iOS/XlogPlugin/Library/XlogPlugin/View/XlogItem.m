//
//  XlogItem.m
//  XlogPlugin
//
//  Created by Damon on 2020/7/19.
//  Copyright © 2020 Damon. All rights reserved.
//

#import "XlogItem.h"

@implementation XlogItem
-(void)configWithAttribute:(NSDictionary *)attribute Path:(NSString *)path{
    
    if (attribute != nil) {
        NSNumber *fileSize = [attribute objectForKey:NSFileSize];
        NSDate *fileModDate = [attribute objectForKey:NSFileModificationDate];
        NSDate *fileCreateDate = [attribute objectForKey:NSFileCreationDate];
        if (fileSize) {
            _fileSize = [NSByteCountFormatter stringFromByteCount:fileSize.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
        }
        if (fileModDate) {
            _motifyDate = [self getTimeWithDate:fileModDate];
        }
        if (fileCreateDate) {
            _createDate = [self getTimeWithDate:fileCreateDate];
            _createtimeInterval = [fileCreateDate timeIntervalSince1970];
        }
        
        if(path){
            _realPath = path;
            _fileName = path.lastPathComponent;
            _type = [path.pathExtension isEqualToString:@"xlog"] ?LOG_TYPE_XLOG:LOG_TYPE_LOG;
        }
    }
}

- (NSString *)getTimeWithDate:(NSDate *)date {
   
    NSString *talkTimeString = nil;
    NSDate *currentDate = [NSDate date];
    //改了过期的API
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday;
    NSDateComponents *currentComponents = [calendar components:unitFlags fromDate:currentDate];
    NSDateComponents *lastComponents = [calendar components:unitFlags fromDate:date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *detailTimeString = [dateFormatter stringFromDate:date];
    
    if (currentComponents.year == lastComponents.year && currentComponents.month == lastComponents.month) {
        if (currentComponents.day == lastComponents.day) {
            talkTimeString = detailTimeString;
        }else if (currentComponents.day == lastComponents.day + 1) {
            talkTimeString = [NSString stringWithFormat:@"昨天 %@",detailTimeString];
        }else if (currentComponents.weekOfYear == currentComponents.weekOfYear) {
            talkTimeString = [NSString stringWithFormat:@"%@ %@",[self weekdayStringWithIndex:lastComponents.weekday],detailTimeString];
        }else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
            talkTimeString = [dateFormatter stringFromDate:date];
        }
    }else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
        talkTimeString = [dateFormatter stringFromDate:date];
    }
    return talkTimeString;
}
- (NSString *)weekdayStringWithIndex:(NSInteger)weekday {
    NSArray *weekdays = @[@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
    return weekdays[weekday-1];
}

- (void)drawRect:(CGRect)rect {

    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    CGContextFillRect(context, rect);
    
    //上分割线，
    
    //CGContextSetStrokeColorWithColor(context, COLORWHITE.CGColor);
    
    //CGContextStrokeRect(context, CGRectMake(5, -1, rect.size.width - 10, 1));
    
    //下分割线
    
    //设置分割线的颜色
    
    CGContextSetStrokeColorWithColor(context,[UIColor colorWithRed:230/255 green:230/255 blue:230/255 alpha:0.8].CGColor);
    
    //设置分割线的位置,给1的粗
    
    CGContextStrokeRect(context,CGRectMake(0, rect.size.height-0.5, rect.size.width,1));

}
@end
