//
//  CoverView.swift
//  Xlog解压工具
//
//  Created by kaoji on 2021/1/30.
//  Copyright © 2021 Damon. All rights reserved.
//

import Cocoa

class CoverView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // #1d161d
        NSColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).setFill()
        dirtyRect.fill()
    }
    
}
