//
//  TableView.swift
//  TableView
//
//  Created by Alberto Moral on 07/10/2017.
//  Copyright © 2017 Alberto Moral. All rights reserved.
//

import Cocoa

class TableView: BaseView {
    var scrollViewTableView = NSScrollView()
    
    var tableView: NSTableView = {
        let table = NSTableView(frame: .zero)
        table.rowSizeStyle = .large
        table.backgroundColor = .clear
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column"))
        table.headerView = nil
        column.width = 1
        table.addTableColumn(column)
        return table
    }()
    
    override func addSubviews() {
        scrollViewTableView.documentView = tableView
        [scrollViewTableView].forEach(addSubview)
    }
    
    override func addConstraints() {
        scrollViewTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([scrollViewTableView.topAnchor.constraint(equalTo: scrollViewTableView.superview!.topAnchor),
                                     scrollViewTableView.leadingAnchor.constraint(equalTo: scrollViewTableView.superview!.leadingAnchor),
                                     scrollViewTableView.trailingAnchor.constraint(equalTo: scrollViewTableView.superview!.trailingAnchor),
                                     scrollViewTableView.bottomAnchor.constraint(equalTo: scrollViewTableView.superview!.bottomAnchor)
                                    ])
    }
}

