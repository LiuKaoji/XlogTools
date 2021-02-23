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

