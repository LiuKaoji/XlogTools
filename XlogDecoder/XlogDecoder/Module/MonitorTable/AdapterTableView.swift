//
//  AdapterTableView.swift
//  TableView
//
//  Created by Alberto Moral on 07/10/2017.
//  Copyright © 2017 Alberto Moral. All rights reserved.
//

import Cocoa

class AdapterTableView: NSObject {
    fileprivate static let column = "column"
    fileprivate static let heightOfRow: CGFloat = 26
    
    fileprivate var items: [MonitorModel] = [MonitorModel]() {
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
        
    func add(items: [MonitorModel]) {
        self.items += items
    }
}

extension AdapterTableView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard (tableColumn?.identifier)!.rawValue == AdapterTableView.column else { fatalError("AdapterTableView identifier not found") }
        let model:MonitorModel = items[row]
        let name = "进房:\(model.time) App:\(model.sdkAppid) 房间号:\(model.roomId) 用户:\(model.userId)"
        let view = NSTextField(string: name)
        view.isEditable = false
        view.isBordered = false
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return AdapterTableView.heightOfRow
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let selectedRow = tableView.selectedRow
        
        /// Mac 有-1的
        guard selectedRow >= 0  else{
            return
        }
        
        let model = items[selectedRow]
        
        var monitorLink = "http://monitor.yy.isd.com/trtc/monitor?userId=\(model.userId)&roomNum=\(model.roomId)&roomStr=\(model.roomId)&sdkAppId=\(model.sdkAppid)&createTime=\(model.timestamp)"
        monitorLink = monitorLink.replacingOccurrences(of: " ", with: "")
        monitorLink = monitorLink.replacingOccurrences(of: "()", with: "")
        
        
        guard let monitorURL = URL(string:monitorLink) else {
           debugPrint("Open MonitorURL Error")
           return
        }

        NSWorkspace.shared.open(monitorURL)
    }
    
}
