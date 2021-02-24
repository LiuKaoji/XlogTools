//
//  DecViewController.swift
//  XlogDecoder
//
//  Created by kaoji on 2020/8/29.
//  Copyright © 2020 kaoji. All rights reserved.
//

import Cocoa
import Python
import MMKV

class DecViewController: NSViewController,DropViewDelegate,DecManagerDelegate {

    var autoOpenState:Bool =  MMKV.default()?.bool(forKey: K_Open) ?? false///但文件自动解压
    var autoCheckState:Bool =  MMKV.default()?.bool(forKey: K_Check) ?? false///自动检测进房事件
    var decItems :Array<DecItem>?
    @IBOutlet weak var pyTextField: NSTextField!
    @IBOutlet weak var versionSegment: NSSegmentedControl!
    @IBOutlet weak var autoOpenBox:  NSButton!
    @IBOutlet weak var autoCheckBox: NSButton!
    @IBOutlet weak var dropView: DropView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decItems = Array<DecItem>()
        loadConfig()
    }
   
    //MARK: UI
    func loadConfig(){
        
        /// 初始化 是否单文件自动打开
        self.autoOpenBox.state = autoOpenState ?.on:.off
        
        /// 初始化 是否自动检测进房事件
        self.autoCheckBox.state = autoCheckState ?.on:.off
        
        /// 初始化 脚本版本选中
        let userIndex:Int = (MMKV.default()?.bool(forKey: K_Script) ?? false) ?1:0
        self.versionSegment.selectedSegment = userIndex
        
        /// 拖拽代理
        dropView.delegate = self
        
        /// 解压代理
        DecManager.manager.delegate = self
        
        /// 获取当前Python版本
        let pyVersionStr  = String.init(cString: Py_GetVersion())
        let result = pyVersionStr.components(separatedBy: " ")
        pyTextField.stringValue = "您当前正使用 Python" + "(" + (result.first ?? "unknown") + ")"
        
        /// 设置HUD样式
        configHUD()
    }
    

    //MARK: 点击事件
    @IBAction func onScriptSegmentChange(_ sender: Any) {
        
        UserDefaults.standard.set(self.versionSegment.selectedSegment, forKey: "VersionTag")
        let is3X = (self.versionSegment.selectedSegment == 0) ?false:true
        DecManager.manager.updateScriptVersion(is3X)
        
        debugPrint("切换脚本")
    }
    
    @IBAction func onClickAutoOpen(_ sender: Any) {
        
        autoOpenState =  ((self.autoOpenBox.state == .on) ?true:false)
        MMKV.default()?.set(autoOpenState, forKey: K_Open)
        
    }
    @IBAction func onClickRoomCheck(_ sender: Any) {
        
        autoCheckState =  ((self.autoCheckBox.state == .on) ?true:false)
        MMKV.default()?.set(autoCheckState, forKey: K_Check)
    }
    

    func toOpenFile(decodedPath:String){

        //若文件存在 主动打开
        if(FileManager.default.fileExists(atPath: decodedPath) == false){return}

        //打开并选中解压的文件
        //NSWorkspace.shared.selectFile(decodedPath, inFileViewerRootedAtPath: "")
        //若这么写10.14版本路径不对，无法自动打开
        //OpenWith.open(decodedPath, withAppAtUrl: URL.init(fileURLWithPath: "/System/Applications/Utilities/Console.app"))
        //使用系统默认的打开方式
        NSWorkspace.shared.openFile(decodedPath)
    }
}

//MARK: 拖拽代理事件
extension DecViewController{

    
    func dropFiles(fileURLs: Array<String>, isAny: Bool) {
        
        DecManager.manager.decItems(files: fileURLs) { [weak self] (items) -> (Void) in
            self?.decItems = items
            
            /// 单文件解压 是否需要自动打开
            if(fileURLs.count == 1 && self?.autoOpenState == true){
                
                self?.toOpenFile(decodedPath: fileURLs[0] + ".log")
            }
            
           
            /// 解释到进房数据 弹窗展示
            if(items.count > 0){
                
                let st = NSStoryboard.init(name: "Main", bundle: nil)
                let enterVC: EnterViewController = st.instantiateController(withIdentifier: .init("EnterViewController")) as! EnterViewController
                self?.addChild(enterVC)
                enterVC.items = items
                self?.presentAsModalWindow(enterVC)
                
            }
        }
    }
    
    func dropInvalid() {}
}

extension DecViewController{
    
    
    func onDecStart() {
        ProgressHUD.show(progress: 0, status: "请稍后...")
    }
    
    func onDecProgressUpdate(progress: Double, progessText: String) {
        ProgressHUD.show(progress: progress, status: "请稍后...")
    }
    
    func onDecFinish() {
        
        ProgressHUD.dismiss()
    }
    
    func configHUD() {
        //ProgressHUD.setDefaultStyle(.light)
        //ProgressHUD.setDefaultMaskType(.black)
        ProgressHUD.setDefaultPosition(.center)
        ProgressHUD.setContainerView(view)
    }
    
}
