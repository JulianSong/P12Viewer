//
//  WindowController.h
//  P12Viewer
//
//  Created by imac-dev on 15/7/1.
//  Copyright (c) 2015年 com.jullian. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WindowController : NSWindowController
@property (weak) IBOutlet NSPopUpButtonCell *fileType;
@property (weak) IBOutlet NSTextFieldCell *p12Paddword;
@property (weak) IBOutlet NSButtonCell *selectFileButton;
@property (weak) IBOutlet NSToolbarItem *openFileButton;
- (IBAction)openFIle:(NSToolbarItem *)sender;
- (IBAction)selectFileType:(NSPopUpButtonCell *)sender;
- (IBAction)open:(NSToolbarItem *)sender;

@end
