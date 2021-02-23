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
    
    func showInComma(source: String, gap: Int=3, seperator: Character=",") -> String {
            var temp = source
            /* 获取目标字符串的长度 */
            let count = temp.count
            /* 计算需要插入的【分割符】数 */
            let sepNum = count / gap
            /* 若计算得出的【分割符】数小于1，则无需插入 */
            guard sepNum >= 1 else {
                return temp
            }
            /* 插入【分割符】 */
            for i in 1...sepNum {
                /* 计算【分割符】插入的位置 */
                let index = count - gap * i
                /* 若计算得出的【分隔符】的位置等于0，则说明目标字符串的长度为【分割位】的整数倍，如将【123456】分割成【123,456】，此时如果再插入【分割符】，则会变成【,123,456】 */
                guard index != 0 else {
                    break
                }
                /* 执行插入【分割符】 */
                temp.insert(seperator, at: temp.index(temp.startIndex, offsetBy: index))
            }
            return temp
    }
}
