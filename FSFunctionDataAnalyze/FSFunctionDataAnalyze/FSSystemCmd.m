//
//  FSSystemCmd.m
//  FSFunctionDataAnalyze
//
//  Created by Kinarobin on 2022/4/13.
//

#import "FSSystemCmd.h"

@implementation FSSystemCmd

+ (FSSystemCmd *)exec:(NSArray <NSString *>*)cmd {
    FSSystemCmd *systemCmd = FSSystemCmd.new;
    
    NSTask *task =  NSTask.new;
    task.launchPath = @"/usr/bin/env";
    if (cmd.count > 0 && cmd.firstObject.length > 0) {
        task.arguments = cmd;
        NSPipe *outPipe = NSPipe.new;
        task.standardOutput = outPipe;
        NSPipe *errPipe = NSPipe.new;
        task.standardError = errPipe;
        NSError *error;
        [task launchAndReturnError:&error];
        
        NSData *outData = outPipe.fileHandleForReading.readDataToEndOfFile;
        NSData *errData = errPipe.fileHandleForReading.readDataToEndOfFile;
        [task waitUntilExit];
        
        NSString *outputString = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
        NSString *errString = [[NSString alloc] initWithData:errData encoding:NSUTF8StringEncoding];
         
        systemCmd.outputString = outputString;
        systemCmd.errString = errString;
        systemCmd.terminationStatus = task.terminationStatus;
    }
    return systemCmd;
}

@end
