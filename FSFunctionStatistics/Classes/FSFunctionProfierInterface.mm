//
//  FSFunctionProfierInterface.mm
//  FSFunctionStatistics
//
//  Created by Kinarobin on 2022/4/2.
//

#include "FSFunctionProfierInterface.h"
#include "FSFunctioneProfiler.h"
#import <Foundation/Foundation.h>
#import <string>

static FSInstrument::CFunctionProfiler *g_profiler = NULL;

extern "C" {
    void startProfiler(thread_t thread, const char *imageName, const char *dataName) {
        if (g_profiler) {
            stopProfiler();
        }
        
        g_profiler = new FSInstrument::CFunctionProfiler(thread, imageName);
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *functionRecord = [cachePath stringByAppendingPathComponent:@"func_record"];
        if (![NSFileManager.defaultManager fileExistsAtPath:functionRecord isDirectory:NULL]) {
            [NSFileManager.defaultManager createDirectoryAtPath:functionRecord withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *path = [functionRecord stringByAppendingPathComponent:@(dataName)];
        g_profiler->setOutputPath(path.UTF8String);
    }
    
    void stopProfiler(void) {
        delete g_profiler;
        g_profiler = NULL;
    }
    
    void __attribute__((__no_instrument_function__))
    __cyg_profile_func_enter(void *this_func, void *call_site)
    {
        if (g_profiler) {
            g_profiler->onFunctionCall(this_func);
        }
    }
    void __attribute__((__no_instrument_function__))
    __cyg_profile_func_exit(void *this_func, void *call_site)
    {
        if (g_profiler) {
            g_profiler->onFunctionExit(this_func);
        }
    }
}
