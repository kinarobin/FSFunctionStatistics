//
//  main.m
//  FSFunctionStatistics
//
//  Created by kinarobin on 04/12/2022.
//  Copyright (c) 2022 kinarobin. All rights reserved.
//

@import UIKit;
#import "FSAppDelegate.h"
#import <FSFunctionStatistics/FSFunctionProfierInterface.h>
#import <mach-o/dyld.h>
#import <objc/message.h>

int main(int argc, char * argv[]) {
    
    const char *imageName = class_getImageName(NSClassFromString(@"FSAppDelegate"));
    startProfiler(mach_thread_self(), imageName, "demo.data");
    mach_port_deallocate(mach_host_self(), mach_thread_self());
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([FSAppDelegate class]));
    }
}
