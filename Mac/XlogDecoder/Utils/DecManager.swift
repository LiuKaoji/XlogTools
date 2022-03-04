//
//  DecManager.swift
//  XlogDec
//
//  Created by kaoji on 2021/2/21.
//  Copyright © 2021 Damon. All rights reserved.
//

import Foundation
import MMKV

protocol DecManagerDelegate {
    
    func onDecStart()
    
    func onDecProgressUpdate(progress: Double, progessText: String)
    
    func onDecFinish()
    
}

class DecManager: NSObject {
    
    /// 单例
    static let manager = DecManager()
    
   /// 代理
    var delegate: DecManagerDelegate?
    
    /// 脚本
    var scriptPath: String {
        get{
            
           let is3X = MMKV.default()?.bool(forKey: K_Script) ?? false
           return is3X ?S_Py3X:S_Py2X
            
        }
   }
    
    /// 任务线程
    private lazy var taskGroup = DispatchGroup()
    private lazy var decQueue = DispatchQueue.init(label: "com.kaoji.Dec", attributes: [.concurrent])/// 并发队列
    
    /// 数据传递
    typealias DecClourse = ((Array<DecItem>) -> (Void))
    typealias TaskClourse = (([DecItem]?) -> (Void))
    
    //MARK: 解码文件
    public func decItems(files: Array<String>, dec: @escaping DecClourse){
        
        ///任务开始
        if delegate != nil {
            delegate?.onDecStart()
        }
        
        var items = Array<DecItem>()
        
        var parsedCount:Double = 0
        for filePath in files {
            
            decQueue.async(group: taskGroup) {
                
                let fileURL = URL.init(fileURLWithPath: filePath)
                self.parseDecItem(logPath: fileURL, taskClouse: { [self] item in
                    item?.count ?? 0 > 0 ?items.append(contentsOf: item!):nil
                    
                    if delegate != nil {
                        parsedCount += 1
                        let progress = parsedCount/(Double)(files.count)
                        let progressStr = "\((Int)(parsedCount))/\(files.count)"
                        delegate?.onDecProgressUpdate(progress: progress, progessText: progressStr)
                    }
                    
                    debugPrint("[DecManager]解压结束:\(filePath)")
                    
                })
            }
        }
        
        taskGroup.notify(queue: decQueue) {
            
            DispatchQueue.main.async { [self] in
                debugPrint("[Dec Tasks Complete]")
                
                /// 去重排序 如果我批量解压过 会有两种日志 这时候全部拖进来也不影响 不重复
                let filterModels:Array<DecItem> = (items.filterDuplicates({$0.enterEvent}))
                items = filterModels.sorted(by: { (previous, next) -> Bool in
                    return previous.time < next.time
                })
                
                dec(items)/// 任务完成 回调主线程给UI处理
                
                ///任务开始
                if delegate != nil {
                    delegate?.onDecFinish()
                }
                
            }
        };
    }
    
    private func parseDecItem(logPath: URL, taskClouse: @escaping TaskClourse){
        
        let decPath = logPath.path
        
        /// 已解压日志->直接读取进房事件
        if logPath.pathExtension == ".log" {
            if(MMKV.default()?.bool(forKey: K_Check) ?? false){
                taskClouse(self.parseUsingRegx(logPath))///读取进房事件并生成model
            }else{
                taskClouse(nil)
            }
           
            return
        }
        
        ///不加密日志->添加后缀再读取进房事件
        if decPath.contains("LiteAV_R") && !FileManager.default.fileExists(atPath: decPath) {
            try? FileManager.default.copyItem(atPath: logPath.path, toPath: decPath)
           
            if(MMKV.default()?.bool(forKey: K_Check) ?? false){
                taskClouse(self.parseUsingRegx(logPath))///读取进房事件并生成model
            }else{
                taskClouse(nil)
            }
            
            return
        }
        
        
        /// 加密文件先执行解密
        // 01.初始化任务
        let buildTask = Process()
        buildTask.launchPath = "/usr/bin/python"
        
        // 02.传入参数
        buildTask.arguments = [self.scriptPath, logPath.path]
        //buildTask.arguments = ["--version"]
        
        // 03.任务完成回调
        buildTask.terminationHandler = { task in
            DispatchQueue.main.async(execute: {[weak self] in
                debugPrint("[任务结束]-\(logPath.lastPathComponent)")
                
                
                /// 根据是否允许检测 返回不通结果
                if(MMKV.default()?.bool(forKey: K_Check) ?? false){
                    taskClouse(self?.parseUsingRegx(logPath))///读取进房事件并生成model
                }else{
                    taskClouse(nil)
                }

            })
        }
        
        // 开始执行任务
        buildTask.launch()
        
        // 等任务结束释放内存
        buildTask.waitUntilExit()
        
    }
    
    private func parseUsingRegx(_ logPath: URL)->[DecItem]?{
        
        ///解压路径
        var decPath = logPath.path
        if !logPath.path.hasSuffix(".log") {
            decPath = logPath.path + ".log"
        }
        
        /// 文件不存在 可能该任务解压失败
        guard  FileManager.default.fileExists(atPath: decPath) else {
            return nil
        }
        
        /// 读取日志文本内容
        guard  let logs = try? String.init(contentsOfFile: decPath) else {
            return nil
        }
        
        /// 文件内容为空
        guard !logs.isEmpty else {
            return nil
        }
        
        var decArray = Array<DecItem>()
        
        /// 读取EnterRoom事件
        let roomExp = try? NSRegularExpression.init(pattern: Regx_Room, options: .caseInsensitive)
        let roomMatches = roomExp!.matches(in: logs, range: NSRange.init(location: 0, length: logs.count))
        
        /// 尝试读取环境版本信息
        let envExp = try? NSRegularExpression.init(pattern: Regx_Env, options: .caseInsensitive)
        let envMatch = envExp!.firstMatch(in: logs, options: .reportProgress, range: NSRange.init(location: 0, length: logs.count))
        
        var envStr : String?
        var sdkVer : String?
        var device : String?
        var sysVer : String?
        if envMatch?.numberOfRanges ?? 0 > 0{
            envStr = logs.subRangeStr(range: (envMatch?.range(at: 0))!)
            sdkVer = logs.subRangeStr(range: (envMatch?.range(at: 1))!)
            device = logs.subRangeStr(range: (envMatch?.range(at: 2))!)
            sysVer = logs.subRangeStr(range: (envMatch?.range(at: 3))!)
        }
        
        for (_ , matchItem) in roomMatches.enumerated() {
            
            var decItem = DecItem()
            
            decItem.srcPath = logPath.path
            decItem.dstPath = decPath
            
            decItem.enterEvent  = logs.subRangeStr(range: matchItem.range(at: 0))
            decItem.time        = logs.subRangeStr(range: matchItem.range(at: 1))
            decItem.roomId      = logs.subRangeStr(range: matchItem.range(at: 2))
            decItem.userId      = logs.subRangeStr(range: matchItem.range(at: 3))
            decItem.sdkAppid    = logs.subRangeStr(range: matchItem.range(at: 4))
            decItem.timestamp   = "\(String.timeToDecStamp(time: decItem.time))"
            
            let dateStrip = decItem.time.prefix(10)
            decItem.dateStrip = String(dateStrip)
            
            decItem.dayMaxStamp = "\(String.timeToTimeStamp(time: dateStrip + " +8.0 23:59:59.999", inputFormatter: "yyyy-MM-dd +8.0 HH:mm:ss.SSS"))"
            
            decItem.dateRange = String.dateToDayRange(date: String(dateStrip))
            
            if envStr != nil{
                decItem.envInfo = envStr!
                decItem.sdkVer  = sdkVer!
                decItem.device  = device!
                decItem.sysVer  = sysVer!
            }
            
            decArray.append(decItem)
        }
        
        return decArray
    }

}

extension DecManager{
    
    func  updateScriptVersion(_ is3X: Bool){
        
        MMKV.default()?.set(is3X, forKey: K_Script)
        
    }
    
}
