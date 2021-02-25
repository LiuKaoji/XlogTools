//
//  EnterViewController.swift
//  XlogDec
//
//  Created by kaoji on 2021/2/21.
//  Copyright © 2021 Damon. All rights reserved.
//

import Cocoa

class EnterViewController: NSViewController {
    
    fileprivate lazy var adapter: AdapterTableView = {
        
        let at = AdapterTableView(tableView: enterTableView.tableView)
        return at
        
    }()
    
    fileprivate lazy var enterTableView: TableView = {
        
        let tableView = TableView.init(frame: self.view.frame)
        tableView.tableView.rowHeight = 100;
        self.view.addSubview(tableView)
        return tableView
        
    }()
    
    var items :Array<DecItem>? {
        
        didSet{
            self.adapter.config(items: items!)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        
        self.title = "进房事件列表"
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRecivedMenuEvent(notify:)), name: NSNotification.Name(rawValue: "ENTER_MENU_EVENT"), object: nil)
    }
    
    func setupTable(){
        
        self.enterTableView.isHidden = true
        self.view.addSubview(enterTableView)
        self.enterTableView.isHidden = true
    }
    
    
    //MARK: 菜单选项
    @objc func didRecivedMenuEvent(notify: NSNotification) {
        
        let obj = notify.object as! EnterAction
        let decItem = obj.decItem
        
        switch obj.type {
        case .copy:
            /// 复制
            actionForCopy(dec: decItem!)
            
            break
            
        case .position:
            /// 定位文件
            actionForPosition(dec: decItem!)
            
            break
            
        case .fetchLog:
            /// 捞日志
            actionForFetchLog(dec: decItem!)
            
            break
            
        case .kibana:
            /// kibana日志
            actionForKibana(dec: decItem!)
            
            break
            
            
        case .monitor:
            /// 仪表盘
            actionForMonitor(dec: decItem!)
            
            break
            
        default:
            break
        }
        
    }
    
    func actionForCopy(dec: DecItem){
        
        let text = "Time:\(dec.time) SdkAppid:\(dec.sdkAppid) RoomId:\(dec.roomId) UserId:\(dec.userId)"
        let paste = NSPasteboard.init(name: .general)
        paste.clearContents()
        paste.setString(text, forType: .string)
        
    }
    
    func actionForPosition(dec: DecItem){
        
        guard FileManager.default.fileExists(atPath: dec.srcPath) else {
            return
        }
        
        /// 在finder中定位文件
        NSWorkspace.shared.selectFile(dec.dstPath, inFileViewerRootedAtPath: "")
    }
    
    func actionForFetchLog(dec: DecItem) {
        
        var fetchLink = "\(D_Sdklog)userId=\(dec.userId)&sdkappid=\(dec.sdkAppid)&\(dec.dateRange)&fuzzy=false"
        fetchLink = fetchLink.replacingOccurrences(of: " ", with: "")
        fetchLink = fetchLink.replacingOccurrences(of: "()", with: "")
        
        guard let monitorURL = URL(string: fetchLink) else {
            debugPrint("Open MonitorURL Error")
            return
        }
        
        NSWorkspace.shared.open(monitorURL)
        
    }
    
    func actionForKibana(dec: DecItem) {
        
       let sdkAppIdComma =  dec.sdkAppid.showInComma(source: dec.sdkAppid)
        debugPrint("[sdkAppIdComma]-\(sdkAppIdComma)")
        
        var kibanaLink = "\(D_Kibana)_g=(refreshInterval:(display:Off,pause:!f,value:0),time:(from:'\((dec.dateStrip))T00:00:01.000Z',mode:absolute,to:'\((dec.dateStrip))T23:59:59.999Z'))&_a=(columns:!(str_error_msg,str_msg_more,str_userid),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'17440060-98b0-11ea-a9d5-07971abffc5a',key:u32_sdkappid,negate:!f,params:(query:\(dec.sdkAppid),type:phrase),type:phrase,value:'\(sdkAppIdComma)'),query:(match:(u32_sdkappid:(query:\(dec.sdkAppid),type:phrase)))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'17440060-98b0-11ea-a9d5-07971abffc5a',key:str_roomid,negate:!f,params:(query:'\(dec.roomId)',type:phrase),type:phrase,value:'\(dec.roomId)'),query:(match:(str_roomid:(query:'\(dec.roomId)',type:phrase)))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'17440060-98b0-11ea-a9d5-07971abffc5a',key:str_userid,negate:!f,params:(query:'\(dec.userId)',type:phrase),type:phrase,value:'\(dec.userId)'),query:(match:(str_userid:(query:'\(dec.userId)',type:phrase))))),index:'17440060-98b0-11ea-a9d5-07971abffc5a',interval:auto,query:(language:lucene,query:''),sort:!(datatime,asc))"
        kibanaLink = kibanaLink.replacingOccurrences(of: " ", with: "")
        kibanaLink = kibanaLink.replacingOccurrences(of: "()", with: "")
        
        guard let kibanaURL = URL(string:kibanaLink) else {
            debugPrint("Open MonitorURL Error")
            return
        }
        
        NSWorkspace.shared.open(kibanaURL)
    }
    
    func actionForMonitor(dec: DecItem) {
        
        var monitorLink = "\(D_Monitor)userId=\(dec.userId)&roomNum=\(dec.roomId)&roomStr=\(dec.roomId)&sdkAppId=\(dec.sdkAppid)&StartTs=\(dec.timestamp)&EndTs=\(dec.dayMaxStamp)"
        monitorLink = monitorLink.replacingOccurrences(of: " ", with: "")
        monitorLink = monitorLink.replacingOccurrences(of: "()", with: "")
        
        guard let monitorURL = URL(string:monitorLink) else {
            debugPrint("Open MonitorURL Error")
            return
        }
        
        NSWorkspace.shared.open(monitorURL)
    }
}
