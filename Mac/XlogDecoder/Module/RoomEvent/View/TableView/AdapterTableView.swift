//
//  AdapterTableView.swift
//  TableView
//
//  Created by Alberto Moral on 07/10/2017.
//  Copyright © 2017 Alberto Moral. All rights reserved.
//

import Cocoa

protocol AdapterTableViewDelegate {
    func didSelectedItem(item: DecItem)/// 选择了
    func didShareItem(item: DecItem)///共享
}

class AdapterTableView: NSObject {
    fileprivate static let column = "column"
    fileprivate static let heightOfRow: CGFloat = 120
    
    fileprivate var items: [DecItem] = [DecItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var tableView: NSTableView
    
    init(tableView: NSTableView) {
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
        
    func add(items: [DecItem]) {
        self.items += items
    }
    
    func config(items: [DecItem]) {
        self.items = items
    }
}

extension AdapterTableView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard (tableColumn?.identifier)!.rawValue == AdapterTableView.column else { fatalError("AdapterTableView identifier not found") }
        let model:DecItem = items[row]
        
        let theFrame = NSRect.init(x: 0, y: 0, width: self.tableView.frame.width, height: 100)
        let enterView = EnterItemView.init(frame: theFrame)
        enterView.item = model;

        return enterView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return AdapterTableView.heightOfRow
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, toolTipFor cell: NSCell, rect: NSRectPointer, tableColumn: NSTableColumn?, row: Int, mouseLocation: NSPoint) -> String {
        
        return "?????????"
    }

//
//    func tableViewSelectionDidChange(_ notification: Notification) {
//
//        let menu = NSMenu.init(title: "选项")
//        let menuItemTypes:Array<EnterMenuType> = [.copy, .position, .monitor, .kibana, .fetchLog]
//
//        for type in menuItemTypes {
//
//            let menuItem = NSMenuItem.init(title: type.rawValue, action: #selector(onClickMenu(item:)), keyEquivalent: "")
//            menu.addItem(menuItem)
//
//        }
//        //NSMenu.popUpContextMenu(menu, with: <#T##NSEvent#>, for: <#T##NSView#>, with: <#T##NSFont?#>)
//    }
    
    @objc func onClickMenu(item :NSMenuItem) {
        debugPrint("[Menu Click]\(item.title)")
    }

    
}
