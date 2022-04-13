//
//  FSFunctionRecord.mm
//  FSFunctionStatistics
//
//  Created by Kinarobin on 2022/4/2.
//

#include "FSFunctionRecord.h"
#include <string.h>

namespace FSInstrument {
    
    void CEventTime::set() {
        m_time = std::chrono::high_resolution_clock::now();
    }
    
    auto CEventTime::diff(const CEventTime& time) {
        return (m_time - time.m_time).count();
    }

    auto CEventTime::count() const {
        return m_time.time_since_epoch().count();
    }
    
    CFunctionRecord::CFunctionRecord(void *addr, FunctionRecordEventType type, int level) : m_addr(addr), m_event(type), m_level(level) {
        m_eventTime.set();
    }
    
    CFunctionRecord::~CFunctionRecord() {}
    
    size_t CFunctionRecord::blobSize() {
        return sizeof(m_addr) + sizeof(m_event) + sizeof(std::chrono::steady_clock::rep) + sizeof(m_level);
    }

    void CFunctionRecord::write(FILE *fp) {
        char buf[blobSize()];
        memcpy(buf, &m_addr, sizeof(m_addr));
        memcpy(buf + sizeof(m_addr), &m_event, sizeof(m_event));
        auto count = m_eventTime.count();
        memcpy(buf + sizeof(m_addr) + sizeof(m_event), &count, sizeof(count));
        memcpy(buf + sizeof(m_addr) + sizeof(m_event) + sizeof(std::chrono::steady_clock::rep), &m_level, sizeof(m_level));
        fwrite(buf, blobSize(), 1, fp);
    }
}
