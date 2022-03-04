//
//  AppDelegate.swift
//  XlogDecoder
//
//  Created by kaoji on 2020/8/29.
//  Copyright © 2020 kaoji. All rights reserved.
//

import Cocoa
import MMKV

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        MMKV.initialize()
        setupConfiguation()
    }
    
    func setupConfiguation(){
        
        let mmkv = MMKV.default()
        let launched:Bool = mmkv?.bool(forKey: K_Launch) ?? false
        if !launched {
            
            mmkv?.set(false,  forKey: K_Open)/// 默认不单文件打开
            mmkv?.set(true,   forKey: K_Check)/// 默认开启进房检测
            mmkv?.set(false,  forKey: K_Script)///脚本
            mmkv?.set(true,   forKey: K_Launch)///启动过了
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func onClickSourceCode(_ sender: Any) {
        NSWorkspace.shared.open(URL.init(string: "https://github.com/LiuKaoji/XlogDecoder-Mac")!)
    }
    
    @IBAction func onClickCheckForUpdate(_ sender: Any) {
        
        /// Sparkle检查更新版本
    }
    
}

