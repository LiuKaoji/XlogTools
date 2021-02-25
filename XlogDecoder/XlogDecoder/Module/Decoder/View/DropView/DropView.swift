//
//  DropView.swift
//  XlogDec
//
//  Created by kaoji on 2021/2/21.
//  Copyright © 2021 Damon. All rights reserved.
//

import Foundation
import Cocoa

protocol DropViewDelegate: class {
    func dropFiles(fileURLs: Array<String>, isAny: Bool)
    func dropInvalid()
}

class DropView: NSView {
    
    private enum FileExtensionTypes: String {
        case xlog
        case log
        case none
        
        func getImage() -> NSImage? {
            var imageName = "green_down_icon"
            
            switch self {
            case .xlog:
                imageName = "xlog"
            case .log:
                imageName = "log"
            case .none:
                imageName = "row"
            }
            
            guard let image = NSImage(named: imageName) else {
                return nil
            }
            
            return image
        }
    }
    
    // App UI Elements
    private let verticalStackView: NSStackView = {
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
          
        return stackView
    }()
    
    private let dropViewFileExtensionImage: NSImageView = {
        let image = NSImageView()
        image.image = NSImage(named: "green_down_icon")
       
        return image
    }()
    
    private let dropViewInlineMessage: NSTextField = {
        let title = NSTextField()
        title.backgroundColor = .clear
        title.textColor = NSColor.textColor
        title.font = NSFont(name: "Helvetica", size: 20)
        title.stringValue = defaultDropViewTitle
        title.isBezeled = false
        title.isEditable = false
        title.sizeToFit()
        title.translatesAutoresizingMaskIntoConstraints = false
    
        return title
    }()
    
    // Properties
    private var fileURL: URL?
    private var selectedFileExtension: FileExtensionTypes = .none
    private var fileExtensionIsAllowed = false
    private var wasDropAbandoned = false
    private static let defaultDropViewTitle = "请拖拽[*.xlog||*.log](支持多任务)"
    weak var delegate: DropViewDelegate?

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectedFileExtension = .none
        updateViewAfterDragEvent()
        registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue:"NSFilenamesPboardType")])
        setupView()
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
            
        verticalStackView.addArrangedSubview(dropViewFileExtensionImage)
        verticalStackView.addArrangedSubview(dropViewInlineMessage)
        addSubview(verticalStackView)
        
        verticalStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        verticalStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let color = NSColor.textColor
        
        let paddingRect = NSMakeRect(dirtyRect.origin.x + 5, dirtyRect.origin.y + 5, dirtyRect.size.width - 10, dirtyRect.size.height - 10)
        
        let roundedPath = NSBezierPath.init(roundedRect: paddingRect, xRadius: 8, yRadius: 8)
        color.setStroke()
        roundedPath.lineWidth = 2
        roundedPath.setLineDash([6,6,6,6], count: 4, phase: 0)
        roundedPath.stroke()
    }
    
    /// 拖入文件时改变图标
    private func updateViewAfterDragEvent() {
        dropViewFileExtensionImage.image = selectedFileExtension.getImage()
//        dropViewInlineMessage.stringValue = fileExtensionIsAllowed ?
//            fileURL!.lastPathComponent : DropView.defaultDropViewTitle
    }
}


// MARK: NSDraggingDestinatio Delegates
extension DropView {
    
    private func getAndSetFileInfo(drag: NSDraggingInfo) {
        if let board = drag.draggingPasteboard.propertyList(forType:
                   NSPasteboard.PasteboardType(rawValue:"NSFilenamesPboardType")) as? [String],
                   let fileURL_ = board.first {
            fileURL = URL(fileURLWithPath: fileURL_)
            selectedFileExtension = FileExtensionTypes(rawValue: fileURL!.pathExtension.lowercased()) ?? FileExtensionTypes.none
        }
    }
    
    private func isFileExtensionAllowed(drag: NSDraggingInfo) -> Bool {
        return selectedFileExtension != FileExtensionTypes.none
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        wasDropAbandoned = false
        getAndSetFileInfo(drag: sender)
        fileExtensionIsAllowed = isFileExtensionAllowed(drag: sender)
        
        return fileExtensionIsAllowed ? [.copy] : [.delete]
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        wasDropAbandoned = true
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        if !fileExtensionIsAllowed && !wasDropAbandoned {
            updateViewAfterDragEvent()
            delegate?.dropInvalid()
        }
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        updateViewAfterDragEvent()
        
        guard var draggedFiles = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] else { return true }
        
        draggedFiles.removeAll { (oneItem) -> Bool in
            ///移除不是xlog/log格式的文件
            return !oneItem.hasSuffix(".xlog") && !oneItem.hasSuffix(".log")
        }
    
        if fileExtensionIsAllowed {
            delegate?.dropFiles(fileURLs: draggedFiles, isAny: false)
        }
        
        dropViewInlineMessage.stringValue = fileExtensionIsAllowed ?
            "拖入了\(draggedFiles.count)个文件" : DropView.defaultDropViewTitle
        
        return true
    }
}
