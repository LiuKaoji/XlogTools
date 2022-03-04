//
//  DecItem.swift
//  XlogDec
//
//  Created by kaoji on 2021/2/21.
//  Copyright © 2021 Damon. All rights reserved.
//

struct DecItem {
    var enterEvent = ""/// EnterRoom
    var sdkAppid = ""///应用标识
    var roomId = ""///房间Id
    var userId = ""///用户id
    var time = ""///来自日志的时间
    var timestamp = ""///日志时间转UNIX时间戳
    var dayMaxStamp = ""///当天最晚点的时间戳
    var dateRange = ""///捞日志用的时间区间
    var dateStrip = ""///Kibana捞日志会默认填写一整天 
    var srcPath = ""///当天最晚点的时间戳
    var dstPath = ""///当天最晚点的时间戳
    var envInfo = ""///当天最晚点的时间戳
    var sdkVer = ""///SD版本
    var device = ""///设备信息
    var sysVer = ""///系统版本
}

