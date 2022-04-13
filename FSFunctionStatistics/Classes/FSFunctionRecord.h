//
//  FSFunctionRecord.h
//  FSFunctionStatistics
//
//  Created by Kinarobin on 2022/4/2.
//

#ifndef FSFunctionRecord_hpp
#define FSFunctionRecord_hpp

#include <stdio.h>
#include <chrono>

namespace FSInstrument {

    typedef enum {
        Enter,
        Exit
    } FunctionRecordEventType;

    class CEventTime {
    public:
        void set();
        auto diff(const CEventTime& time);
        auto count() const;
        std::chrono::high_resolution_clock::time_point m_time;
    };

    class CFunctionRecord {
    public:
        CFunctionRecord(void *addr, FunctionRecordEventType type, int m_level);
        ~CFunctionRecord();
    public:
        static size_t blobSize();
        void write(FILE *fp);
        FunctionRecordEventType type() { return m_event; }
        void *addr() { return  m_addr; }
    private:
        void *m_addr;
        FunctionRecordEventType m_event;
        CEventTime m_eventTime;
        int m_level;
    };
}


#endif /* FunctionRecord_hpp */
