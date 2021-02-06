//
//  AppDelegate.swift
//  XlogDecoder
//
//  Created by kaoji on 2020/8/29.
//  Copyright © 2020 kaoji. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func onClickSourceCode(_ sender: Any) {
        NSWorkspace.shared.open(URL.init(string: "https://github.com/LiuKaoji/XlogDecoder-Mac")!)
    }
    
}

