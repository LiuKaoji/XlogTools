//
//  ViewController.swift
//  XlogDecoder
//
//  Created by kaoji on 2020/8/29.
//  Copyright © 2020 kaoji. All rights reserved.
//

import Cocoa
import Python

class ViewController: NSViewController,MBDropZoneDelegate {

    var scriptName:String?
    var autoState:Bool =  UserDefaults.standard.bool(forKey: "AutoTag")
    var monitorModels: Array<MonitorModel>?
    @IBOutlet weak var pyTextField: NSTextField!
    @IBOutlet weak var versionSegment: NSSegmentedControl!
    @IBOutlet weak var autoCheckBox: NSButton!
    @IBOutlet weak var backBtn: NSButton!
    
    lazy var monitorView: TableView = .init(frame: self.view.frame)
    fileprivate var adapter: AdapterTableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
   
    //MARK: UI
    func setupUI(){
        
        //初次安装默认自动打开日志
        if UserDefaults.standard.bool(forKey: "DidLauchTag") == false {
            autoState = true
            UserDefaults.standard.set(true, forKey: "DidLauchTag")
        }
        
        //记录用户选择的脚本版本
        let userIndex:Int = UserDefaults.standard.value(forKey: "VersionTag") as? Int ?? 0
        self.versionSegment.selectedSegment = userIndex
        self.versionSegmentValueChange(versionSegment!)
        
        //是否自动打开文件
        self.autoCheckBox.state = autoState ?.on:.off
        
        //创建拖拽文件区域
        let drapZone = MBDropZone.init(frame: self.view.frame)
        drapZone.text = "请拖入文件"
        drapZone.fileType = ".xlog"
        drapZone.delegate = self
        self.view.addSubview(drapZone)
        
        //获取当前Python版本
        let pyVersionStr  = drapZone.convertCString(UnsafeMutablePointer<Int8>.init(mutating: Py_GetVersion()))
        let result = pyVersionStr?.components(separatedBy: " ")
        pyTextField.stringValue = "您当前正使用 Python" + "(" + (result?.first ?? "unknown") + ")"
        
        //进房事件列表
        monitorView.addSubview(backBtn)
        self.view.addSubview(monitorView)
        self.monitorView.isHidden = true
    
    }

    //MARK: 点击事件
    @IBAction func versionSegmentValueChange(_ sender: Any) {
        UserDefaults.standard.set(self.versionSegment.selectedSegment, forKey: "VersionTag")
        scriptName = (self.versionSegment.selectedSegment == 0) ?"decode_mars_log_file":"decode_mars_log_file_3"
        debugPrint("当前使用脚本\(scriptName ?? "")")
    }
    
    @IBAction func onClickAuto(_ sender: Any) {
        autoState =  ((self.autoCheckBox.state == .on) ?true:false)
        UserDefaults.standard.set(autoState, forKey: "AutoTag")
    }
    
    @IBAction func onClickOk(_ sender: Any) {
        self.monitorView.isHidden = true
    }
    
    func configureTableView() {
        adapter = AdapterTableView(tableView: monitorView.tableView)
        adapter?.add(items: monitorModels!)
        self.monitorView.isHidden = false
    }
    
    //MARK: 执行解码动作
    func runScript2Decode(xlogPath: String, autoOpen:Bool){
        
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async {
            
            // 获取脚本地址
            guard let path = Bundle.main.path(forResource: self.scriptName, ofType: "py") else {
                print("Unable to locate script.command")
                return
            }
            
            // 初始化任务
            let buildTask = Process()
            buildTask.launchPath = "/usr/bin/python"
            
            // 传入参数
            buildTask.arguments = [path, xlogPath]
            //buildTask.arguments = ["--version"]
            
            // 任务完成回调
            buildTask.terminationHandler = { task in
                DispatchQueue.main.async(execute: {
                    debugPrint("任务结束")
                    if(autoOpen){
                        self.toOpenFile(decodedPath: xlogPath + ".log")
                        self.toMatchEnterRoom(decodedPath: xlogPath + ".log")
                    }
                })
            }
            
            // 开始执行任务
            buildTask.launch()
            
            // 等任务结束释放内存
            buildTask.waitUntilExit()
        }
    }
    
    func toOpenFile(decodedPath:String){
        
        //若文件存在 主动打开
        if(FileManager.default.fileExists(atPath: decodedPath) == false){return}
        
        //打开并选中解压的文件
        NSWorkspace.shared.selectFile(decodedPath, inFileViewerRootedAtPath: "")
        //若允许自动打开 则使用控制台打开日志
        if(autoState == false){return}
        //若这么写10.14版本路径不对，无法自动打开
        //OpenWith.open(decodedPath, withAppAtUrl: URL.init(fileURLWithPath: "/System/Applications/Utilities/Console.app"))
        //使用系统默认的打开方式
        NSWorkspace.shared.openFile(decodedPath)
    }
    
    func toMatchEnterRoom(decodedPath: String) {
        
        ///test:---------- let testLog = Bundle.main.path(forResource: "an.xlog", ofType: ".log")
        guard  let logs = try? String.init(contentsOfFile: decodedPath) else {
            return
        }
        
        guard logs.count > 0 else {
            return
        }
        
        let regx = "([\\d\\s\\-\\+\\s:\\.]{20,}).*trtc_api[\\s,]+enterRoom roomId:(.*?)\\suserId:(.*?)\\ssdkAppId:(.*?)\\s"
        let regExp = try? NSRegularExpression.init(pattern: regx, options: .caseInsensitive)
        let matches = regExp!.matches(in: logs, range: NSRange.init(location: 0, length: logs.count))
        
        monitorModels = Array<MonitorModel>()
        
        for match in matches {
            var monitorModel = MonitorModel()
            monitorModel.enterEvent = logs.substring(with: Range.init(match.range(at: 0), in: logs)!)
            monitorModel.time = logs.substring(with: Range.init(match.range(at: 1), in: logs)!)
            monitorModel.roomId = logs.substring(with: Range.init(match.range(at: 2), in: logs)!)
            monitorModel.userId = logs.substring(with: Range.init(match.range(at: 3), in: logs)!)
            monitorModel.sdkAppid = logs.substring(with: Range.init(match.range(at: 4), in: logs)!)
            monitorModel.timestamp = "\(timeToTimeStamp(time: monitorModel.time, inputFormatter: "yyyy-MM-dd +8.0 HH:mm:ss.SSS"))"

            monitorModels?.append(monitorModel)
        
        }
        
        guard monitorModels?.count ?? 0 > 0 else {
            return
        }
        
        configureTableView()
    }
    
    ///时间转时间戳
    func timeToTimeStamp(time: String ,inputFormatter:String) -> Int {
        let dfmatter = DateFormatter()
       //设定时间格式,这里可以设置成自己需要的格式
        dfmatter.dateFormat = inputFormatter
        let last = dfmatter.date(from: time)
        let timeStamp = last?.timeIntervalSince1970
        return Int(timeStamp ?? 0)
    }
}

//MARK: 拖拽代理事件
extension ViewController{
    
    func dropZone(_ dropZone: MBDropZone!, receivedFile file: String!, isMultiple: Bool) {
        
        //带LiteAV_R的是未加密日志 直接打开
        if(file.contains("LiteAV_R")){
            let extPath = file + ".log"
            try? FileManager.default.copyItem(atPath: file, toPath: extPath)
            if !isMultiple {
                self.toOpenFile(decodedPath: extPath)
            }
            return
        }
        //使用系统Python和官方xlog解压脚本进行解压,并打开
        self.runScript2Decode(xlogPath: file,autoOpen: !isMultiple)
    }
}

