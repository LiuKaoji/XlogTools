//
//  String + timeStamp.swift
//  Xlog解压工具
//
//  Created by kaoji on 2021/1/31.
//  Copyright © 2021 Damon. All rights reserved.
//

import Cocoa

extension String{
    
    ///时间转时间戳
    static func timeToTimeStamp(time: String ,inputFormatter:String) -> Int {
        let dfmatter = DateFormatter()
       //设定时间格式,这里可以设置成自己需要的格式
        dfmatter.dateFormat = inputFormatter
        let last = dfmatter.date(from: time)
        let timeStamp = last?.timeIntervalSince1970
        return Int(timeStamp ?? 0)
    }
    
    ///时间转时间戳
    static func timeToDayMaxStamp(time: String ,inputFormatter:String) -> Int {
        let dfmatter = DateFormatter()
       //设定时间格式,这里可以设置成自己需要的格式
        dfmatter.dateFormat = inputFormatter
        let last = dfmatter.date(from: time)
        let timeStamp = last?.timeIntervalSince1970
        return Int(timeStamp ?? 0)
    }
}
