//
//  DropZone.h
//  MacSymbolicator
//
//  Created by Mahdi Bchetnia on 7/9/13.
//  Copyright (c) 2013 Mahdi Bchetnia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Python/Python.h>

@protocol MBDropZoneDelegate;

@interface MBDropZone : NSView {
    BOOL _isHoveringFile;
}

@property (weak) id<MBDropZoneDelegate> delegate;
@property (strong, nonatomic) NSImage* icon;
@property (strong, nonatomic) NSString* fileType;
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* detailText;

@property (strong, nonatomic) NSString* file;
- (NSString *)convertCString:(char *)cStr;
@end

@protocol MBDropZoneDelegate <NSObject>
- (void)dropZone:(MBDropZone*)dropZone receivedFile:(NSString*)file isMultiple:(BOOL)isMultiple;

@end
