//
//  Array + ext.swift
//  Xlog解压工具
//
//  Created by kaoji on 2021/1/31.
//  Copyright © 2021 Damon. All rights reserved.
//

import Cocoa

extension Array {
    
    // 去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}
