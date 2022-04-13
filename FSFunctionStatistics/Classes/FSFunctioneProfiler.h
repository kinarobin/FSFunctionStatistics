//
//  FSFunctioneProfiler.h
//  FSFunctionStatistics
//
//  Created by Kinarobin on 2022/4/2.
//

#ifndef FSFunctioneProfiler_hpp
#define FSFunctioneProfiler_hpp

#include <stdio.h>
#include <mach/mach_types.h>
#include <vector>
#include <string>
#include "FSFunctionRecord.h"

namespace FSInstrument {
    class CFunctionProfiler {
    public:
        CFunctionProfiler(thread_t thread, const std::string& imageName);
        ~CFunctionProfiler();
        void onFunctionCall(void* func);
        void onFunctionExit(void* func);
        void flush();
        void setOutputPath(const std::string& path);
    private:
        void write();
        void writeImageSlide();
        void addRecord(void* func,FunctionRecordEventType type);
    private:
        std::vector<CFunctionRecord> m_buf;
        thread_t m_targetThread;
        FILE *m_fp;
        static const size_t s_defaultCacheCount = 1000;
        int m_level;
        bool m_init;
        std::string m_imageName;
    };
}

#endif /* FunctioneProfiler_hpp */
