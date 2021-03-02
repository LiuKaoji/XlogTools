//
//  EnterItemView.swift
//  XlogDec
//
//  Created by kaoji on 2021/2/21.
//  Copyright © 2021 Damon. All rights reserved.
//

import Cocoa
import SnapKit

enum EnterMenuType: String {
    case copy         = "复制信息"/// 复制当前进房信息
    case position     = "定位文件"/// 定位至该进房信息的文件(目前点击仪表盘之后可能还得找哪个日志文件)
    case monitor      = "仪表盘"/// 跳转至仪表盘填写一些数据
    case kibana       = "kibana"/// 查找kibana日志
    case fetchLog     = "当天日志"/// 后台捞日志
    case Environment  = "版本机型"/// SDK版本和机型
}

struct EnterAction {
    
    var type: EnterMenuType!
    var decItem :DecItem!
}

class MouseMaskView: NSView {
    
    typealias ActionClourse = ((EnterMenuType)->(Void))
    
    var actionCallBack: ActionClourse?
    
    convenience required init(action: @escaping ActionClourse) {
        self.init()
        actionCallBack = action
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        let menu = NSMenu.init(title: "选项")
        let menuItemTypes:Array<EnterMenuType> = [.copy, .position, .monitor, .kibana, .fetchLog]
        
        for type in menuItemTypes {
            
            let menuItem = NSMenuItem.init(title: type.rawValue, action: #selector(onClickMenu(mItem:)), keyEquivalent: "")
            menu.addItem(menuItem)
            
        }
        
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    
    @objc func onClickMenu(mItem :NSMenuItem) {
        debugPrint("[Menu Click]\(mItem.title)")
        
        if actionCallBack != nil {
            actionCallBack!(EnterMenuType.init(rawValue: mItem.title)!)
        }
        
    }
}

class EnterItemView: NSView {
    
    var item : DecItem? {
     
        didSet{
            self.appMsg.stringValue  =  "🏬应用:  \(item?.sdkAppid ?? "NULL")"
            self.roomMsg.stringValue =  "👨‍👩‍👧‍👦房间:  \(item?.roomId ?? "NULL")"
            self.userMsg.stringValue =  "🙋‍♂️用户:  \(item?.userId ?? "NULL")"
            self.envMsg.stringValue =   "📱版本:  \(item!.sdkVer) 型号: \(item!.device) 系统: \(item!.sysVer)"
            self.timeMsg.stringValue =  "⏰时间:  \(item?.time   ?? "NULL")"
            
            debugPrint("🏬[_SDK]: \(item?.sdkAppid ?? "NULL")")
        }
    }
    
    private  var appMsg: NSTextField!
    
    private var roomMsg: NSTextField!
    
    private var userMsg: NSTextField!
    
    private var envMsg: NSTextField!
    
    private var timeMsg: NSTextField!
    
    private var maskView: MouseMaskView!


    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupEnterView()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupEnterView()
    }
    
    func setupEnterView(){
        
        self.wantsLayer = true
        self.layer?.borderWidth = 1
        self.layer?.borderColor = NSColor.separatorColor.cgColor
        self.layer?.cornerRadius = 8
        
        appMsg  = createTitleView(font: NSFont.boldSystemFont(ofSize: 13), textColor: NSColor.textColor)
        roomMsg = createTitleView(font: NSFont.boldSystemFont(ofSize: 13), textColor: NSColor.textColor)
        userMsg = createTitleView(font: NSFont.boldSystemFont(ofSize: 13), textColor: NSColor.textColor)
        envMsg = createTitleView(font: NSFont.boldSystemFont(ofSize: 13), textColor: NSColor.textColor)
        timeMsg = createTitleView(font: NSFont.boldSystemFont(ofSize: 13), textColor: NSColor.textColor)
        
        maskView = MouseMaskView.init(action: { (type) -> (Void) in
            
            var obj = EnterAction()
            obj.decItem = self.item
            obj.type = type
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ENTER_MENU_EVENT"), object: obj)
            
        })
        
        self.addSubview(appMsg)
        self.addSubview(roomMsg)
        self.addSubview(envMsg)
        self.addSubview(userMsg)
        self.addSubview(timeMsg)
        self.addSubview(maskView)
        
        self.appMsg.snp.makeConstraints { (make) in
            make.left.top.equalTo(15)
            make.width.equalTo(self)
            make.height.equalTo(20)
        }
        
        self.roomMsg.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(appMsg.snp.bottom)
            make.width.equalTo(self)
            make.height.equalTo(20)
        }
        
        self.userMsg.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(roomMsg.snp.bottom)
            make.width.equalTo(self)
            make.height.equalTo(20)
        }
        
        self.envMsg.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(userMsg.snp.bottom)
            make.width.equalTo(self)
            make.height.equalTo(20)
        }
        
        self.timeMsg.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(envMsg.snp.bottom)
            make.width.equalTo(self)
            make.height.equalTo(20)
        }
        
        maskView.snp.makeConstraints { (make) in
            make.left.top.width.height.equalToSuperview()
        }
    }
    
    func createTitleView(font: NSFont, textColor: NSColor) -> NSTextField{
        
        let title = NSTextField()
        title.backgroundColor = .clear
        title.textColor = textColor
        title.font = font
        title.isBezeled = false
        title.isEditable = false
        return title
    }

}
