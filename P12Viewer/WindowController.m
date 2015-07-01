//
//  WindowController.m
//  P12Viewer
//
//  Created by imac-dev on 15/7/1.
//  Copyright (c) 2015年 com.jullian. All rights reserved.
//

#import "WindowController.h"
#import "ViewController.h"
static NSString *const OPEN_P12 = @"openssl pkcs12 -nokeys -in %@ -nodes -passin pass:\"%@\"";
static NSString *const OPEN_mobileprovision = @"openssl smime -inform der -verify -noverify -in %@";
@interface WindowController ()
{
    NSURL *fileUrl ;
    NSString *_command;
}
@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (IBAction)openFIle:(NSToolbarItem *)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"p12", @"mobileprovision"]];
    NSInteger clicked = [panel runModal];
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            fileUrl = url;
        }
    }
//    [self.openFileButton setMinSize:NSMakeSize(100,30)];
    NSRect e = [[NSScreen mainScreen] frame];
    [self.openFileButton setMaxSize:NSMakeSize(e.size.width+200,30)];
    [self.selectFileButton setTitle:fileUrl.description];
}

- (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    NSPipe *errorPipe = [NSPipe pipe];
    [task setStandardError:errorPipe];
    NSFileHandle *errorFile = [errorPipe fileHandleForReading];
    
    
    [task launch];

    [task setTerminationHandler:^(NSTask *task) {
        
        if (task.terminationStatus) {
            //        NSError *error = [NSError errorWithDomain:@"P12Viewer" code:100 userInfo:@{}];
            //        NSAlert *alert =  [NSAlert alertWithError:error];
            NSData *errorData = [errorFile readDataToEndOfFile];
            
            NSString *errorOutput = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
            [self showAlert:errorOutput];
        }
    }];
    

    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return output;
}

- (IBAction)selectFileType:(NSPopUpButtonCell *)sender {
    if (sender.indexOfSelectedItem == 0) {
        self.p12Paddword.editable = YES;
    }else{
        self.p12Paddword.editable = NO;
    }
}

-(void)showAlert:(NSString *)info
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Error"];
    [alert setInformativeText:info];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
}

- (IBAction)open:(NSToolbarItem *)sender {
    
    if (fileUrl == nil) {
        [self showAlert:@"please select a file !"];
        return;
    }
    
    
    
    ViewController *vc = (ViewController *)self.contentViewController;
    [vc.resultView setString:@""];
    if ([fileUrl.pathExtension isEqualToString:@"p12"]) {
        _command = [NSString  stringWithFormat:OPEN_P12,fileUrl.path,self.p12Paddword.stringValue];
    }else if ([fileUrl.pathExtension isEqualToString:@"mobileprovision"]){
        _command = [NSString  stringWithFormat:OPEN_mobileprovision,fileUrl.path];
    }
    
    [vc.resultView setString:[self runCommand:_command]];
}
@end
