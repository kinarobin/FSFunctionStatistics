//
//  FSFunctioneProfiler.mm
//  FSFunctionStatistics
//
//  Created by Kinarobin on 2022/4/2.
//

#include "FSFunctioneProfiler.h"
#include <string>
#include <dispatch/dispatch.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <mach/mach_init.h>
#include <mach/mach_port.h>

extern "C" {
    int main(int argc, char * argv[]);
}

namespace FSInstrument {
    static dispatch_queue_t s_writeQueue = dispatch_queue_create("CFunctionProfiler", DISPATCH_QUEUE_SERIAL);
    CFunctionProfiler::CFunctionProfiler(thread_t thread, const std::string& imageName) {
        m_targetThread = thread;
        m_fp = NULL;
        m_level = 0;
        m_init = true;
        m_imageName = imageName;
    }
    
    CFunctionProfiler::~CFunctionProfiler() {
        if (!m_buf.empty() && m_buf.back().type() == Enter) {
            addRecord(m_buf.back().addr(), Exit);
        }
        
        write();
        if (m_fp == NULL) {
            return;
        }
        dispatch_sync(s_writeQueue, ^{
            fclose(m_fp);
        });
        m_fp = NULL;
    }

    void CFunctionProfiler::onFunctionCall(void *func) {
        addRecord(func, Enter);
    }

    void CFunctionProfiler::onFunctionExit(void* func) {
        addRecord(func, Exit);
    }

    void CFunctionProfiler::addRecord(void *func, FunctionRecordEventType type) {
        mach_port_t target = mach_thread_self();
        mach_port_deallocate(mach_task_self_, target);
        if (target != m_targetThread) {
            return;
        }
        
        if (m_init) {
            m_init = false;
            if (type == Exit) {
                return;
            }
        }
        
        func = (void*)((long)func & 0x0fffffffff);
        
        if (type == Enter) {
            m_level++;
        }
        
        CFunctionRecord record(func, type, m_level);
        
        if (type == Exit) {
            m_level--;
        }
        
        m_buf.emplace_back(record);
        
        if (m_buf.size() >= s_defaultCacheCount) {
            flush();
        }
    }

    void CFunctionProfiler::flush() {
        write();
        m_buf.clear();
    }

    void CFunctionProfiler::setOutputPath(const std::string &path) {
        dispatch_sync(s_writeQueue, ^{
            if (m_fp) {
                fclose(m_fp);
            }
            
            m_fp = fopen(path.c_str(), "wb");
            writeImageSlide();
        });
    }

    void CFunctionProfiler::write() {
        auto tmp = m_buf;
        FILE *f = m_fp;
        dispatch_async(s_writeQueue, ^{
            for_each(tmp.begin(), tmp.end(), [f](auto item) -> void {
                item.write(f);
            });
        });
    }

    void CFunctionProfiler::writeImageSlide() {
        int index = 0;
        for (int mainImageIndex = 0; mainImageIndex < _dyld_image_count(); mainImageIndex++) {
            const char *name = _dyld_get_image_name(mainImageIndex);
            if (m_imageName == name) {
                index = mainImageIndex;
                break;
            }
        }
        
        void *image_header = (void *)_dyld_get_image_header(index);
        FILE *f = m_fp;
        dispatch_async(s_writeQueue, ^{
            fwrite(&image_header, sizeof(void *), 1, f);
        });
    }
}
