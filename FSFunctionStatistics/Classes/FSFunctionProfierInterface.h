//
//  FSFunctionProfierInterface.h
//  FSFunctionStatistics
//
//  Created by Kinarobin on 2022/4/2.
//

#ifndef FSFunctionProfierInterface_h
#define FSFunctionProfierInterface_h

#include <stdio.h>
#include <mach/mach.h>

#if defined(__cplusplus)
extern "C" {
#endif

void startProfiler(thread_t thread, const char *imageName, const char *dataName);
void stopProfiler(void);

#if defined(__cplusplus)
}
#endif

#endif /* FunctionProfierInterface_h */
