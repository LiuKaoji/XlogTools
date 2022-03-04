//
//  DecConst.swift
//  XlogDec
//
//  Created by kaoji on 2021/2/22.
//  Copyright © 2021 Damon. All rights reserved.
//

import Foundation

/// ==========Domain Prefix==========
let D_Kibana  = "http://essdk.kibana.qcloud.com/app/kibana#/discover?"
let D_Monitor = "http://monitor.yy.isd.com/trtc/monitor?"
let D_Sdklog  = "https://sdklog.trtc.woa.com/SdkLog/home?"

/// ==========MMKV==========
let K_Open    = "AutoOpen"
let K_Check   = "AutoCheck"
let K_Launch  = "Launched"
let K_Script  = "Script"

/// ==========Scripst==========
let S_Bundle   =  Bundle.main.path(forResource: "Scripts", ofType: "bundle")!
let S_Py2X     =  S_Bundle + "/decode_mars_log_file.py"
let S_Py3X     =  S_Bundle + "/decode_mars_log_file_3.py"

/// ==========正则表达式==========
/*
   匹配进房事件[roomId, userId, sdkAppId]
   enterRoom roomId:xxxx userId:xxxx sdkAppId:xxxx appSence:xxxx role:xxx
 */
let Regx_Room = "([\\d\\s\\-\\+\\s:\\.]{20,}).*trtc_api[\\s,]+enterRoom roomId:(.*?)\\suserId:(.*?)\\ssdkAppId:(.*?)\\s"

/*
   匹配SDK版本机型系统信息[sdkVer, model, sysVer]
   SDK Version:7.8.9519 Device Name:iPad 5G (9.7-Inch) (Wi-Fi) System Version:14.4
 */
let Regx_Env = "SDK Version:([^=]*)Device Name:([^=]*)System Version:([^=]*)"
