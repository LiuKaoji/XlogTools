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
    typealias TaskClourse = ((DecItem?) -> (Void))
    
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
                    (item != nil && (item?.sdkAppid.count ?? 0) > 0) ?items.append(item!):nil
                    
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
    
    private func parseUsingRegx(_ logPath: URL) -> DecItem?{
        
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
        
        /// 读取EnterRoom事件
        let regx = "([\\d\\s\\-\\+\\s:\\.]{20,}).*trtc_api[\\s,]+enterRoom roomId:(.*?)\\suserId:(.*?)\\ssdkAppId:(.*?)\\s"
        let regExp = try? NSRegularExpression.init(pattern: regx, options: .caseInsensitive)
        let matches = regExp!.matches(in: logs, range: NSRange.init(location: 0, length: logs.count))
        
        var decItem = DecItem()
        for match in matches {
            
            decItem.enterEvent = logs.substring(with: Range.init(match.range(at: 0), in: logs)!)
            decItem.time = logs.substring(with: Range.init(match.range(at: 1), in: logs)!)
            decItem.roomId = logs.substring(with: Range.init(match.range(at: 2), in: logs)!)
            decItem.userId = logs.substring(with: Range.init(match.range(at: 3), in: logs)!)
            decItem.sdkAppid = logs.substring(with: Range.init(match.range(at: 4), in: logs)!)
            decItem.timestamp = "\(String.timeToTimeStamp(time: decItem.time, inputFormatter: "yyyy-MM-dd +8.0 HH:mm:ss.SSS"))"
            
            let dateStrip = decItem.time.prefix(10)
            decItem.dateStrip = String(dateStrip)
            
            decItem.dayMaxStamp = "\(String.timeToTimeStamp(time: dateStrip + " +8.0 23:59:59.999", inputFormatter: "yyyy-MM-dd +8.0 HH:mm:ss.SSS"))"
            
            decItem.dateRange = "daterange[]=\(dateStrip) 00:00:00&daterange[]=\(dateStrip) 23:59:59"
            
            decItem.srcPath = logPath.path
            decItem.dstPath = decPath
        }
        return decItem
    }
}

extension DecManager{
    
    func  updateScriptVersion(_ is3X: Bool){
        
        MMKV.default()?.set(is3X, forKey: K_Script)
        
    }
    
}
