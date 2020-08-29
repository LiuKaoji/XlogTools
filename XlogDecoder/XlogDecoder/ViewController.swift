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
    @IBOutlet weak var pyTextField: NSTextField!
    @IBOutlet weak var versionSegment: NSSegmentedControl!
    @IBOutlet weak var autoCheckBox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
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
    }

    @IBAction func versionSegmentValueChange(_ sender: Any) {
        UserDefaults.standard.set(self.versionSegment.selectedSegment, forKey: "VersionTag")
        scriptName = (self.versionSegment.selectedSegment == 0) ?"decode_mars_log_file":"decode_mars_log_file_3"
        debugPrint("当前使用脚本\(scriptName ?? "")")
    }
    
    @IBAction func onClickAuto(_ sender: Any) {
        autoState =  ((self.autoCheckBox.state == .on) ?true:false)
        UserDefaults.standard.set(autoState, forKey: "AutoTag")
    }
    
    func runScript2Decode(xlogPath: String){
        
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
                    self.toOpenFile(decodedFilePath: xlogPath + ".log")
                })
            }
            
            // 开始执行任务
            buildTask.launch()
            
            // 等任务结束释放内存
            buildTask.waitUntilExit()
        }
    }
    
    func toOpenFile(decodedFilePath:String){
        
        //若文件存在 主动打开
        if(FileManager.default.fileExists(atPath: decodedFilePath) == false){return}
        
        //打开并选中解压的文件
        NSWorkspace.shared.selectFile(decodedFilePath, inFileViewerRootedAtPath: "")
        //若允许自动打开 则使用控制台打开日志
        if(autoState == false){return}
        OpenWith.open(decodedFilePath, withAppAtUrl: URL.init(fileURLWithPath: "/System/Applications/Utilities/Console.app"))
    }
}

extension ViewController{
    
    func dropZone(_ dropZone: MBDropZone!, receivedFile file: String!) {
        
        //带LiteAV_R的是未加密日志 直接打开
        if(file.contains("LiteAV_R")){
            self.toOpenFile(decodedFilePath: file)
            return
        }
        //使用系统Python和官方xlog解压脚本进行解压,并打开
        self.runScript2Decode(xlogPath: file)
    }
}
