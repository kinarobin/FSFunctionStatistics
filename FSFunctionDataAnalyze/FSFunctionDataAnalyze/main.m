//
//  main.m
//  FSFunctionDataAnalyze
//
//  Created by Kinarobin on 2022/4/13.
//

#import <Foundation/Foundation.h>
#import "FSFuncRecord.h"
#import "FSFuncProcessor.h"
#import "FSFuncDataFotmator.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 4) {
            [NSException raise:@"用法有误！" format:@"0：需要解析的数据 1：dsym符号文件 2：输出的文件"];
        }
        NSURL *filePathURL = [NSURL fileURLWithPath:@(argv[1])];
        NSURL *symPath = [NSURL fileURLWithPath:@(argv[2])];
        NSURL *outputURL = [NSURL fileURLWithPath:@(argv[3])];
        
        if (access(filePathURL.path.UTF8String, F_OK) == -1) {
            printf("analyze file not exist:%s\n", filePathURL.path.UTF8String);
            abort();
        }
        
        if (access(symPath.path.UTF8String, F_OK) == -1) {
            printf("dsym file not exist:%s\n", symPath.path.UTF8String);
            abort();
        }
        
        int pointLength = sizeof(void *);
        int int64Length = sizeof(int64_t);
        int int32Length = sizeof(int32_t);
        
        NSData *analyzeData = [NSData dataWithContentsOfURL:filePathURL];
        if ((analyzeData.length - pointLength) % 24 != 0) {
            [NSException raise:@"需要解析的数据有错误，请检查" format:@""];
        }
        
        int64_t imageSlide = 0;
        long long offset = 0;
        [analyzeData getBytes:&imageSlide range:NSMakeRange(0, pointLength)];
        offset += pointLength;
        NSMutableArray *functionRecords = NSMutableArray.array;
        do {
            int64_t addr = 0;
            [analyzeData getBytes:&addr range:NSMakeRange(offset, int64Length)];
            offset += int64Length;
            
            int32_t type = 0;
            [analyzeData getBytes:&type range:NSMakeRange(offset, int32Length)];
            offset += int32Length;
            
            int64_t time = 0;
            [analyzeData getBytes:&time range:NSMakeRange(offset, int64Length)];
            offset += int64Length;
            time /= 1000;
            
            int32_t level = 0;
            [analyzeData getBytes:&level range:NSMakeRange(offset, int32Length)];
            offset += int32Length;
            
            FSFuncRecord *record = FSFuncRecord.new;
            record.addr = addr;
            record.state = type == 0 ? FSFunctionEnterState : FSFunctionExitState;
            if (record.state == FSFunctionEnterState) {
                record.begin = time;
            } else {
                record.end = time;
            }
            record.level = level;
            [functionRecords addObject:record];
            
        } while (offset < analyzeData.length);
        
        FSFuncProcessor *funcProcessor =
            [[FSFuncProcessor alloc] initWithFunctionRecords:functionRecords
                                                 imageSlider:imageSlide
                                                    dsymPath:symPath.path];
        NSArray *resules = [funcProcessor process];
        
        FSFuncDataFotmator *dataFotmator = FSFuncDataFotmator.new;
        NSData *data = [dataFotmator formatDataWithRecords:resules];
        
        NSError *error;
        [data writeToURL:outputURL options:0 error:&error];
        if (error) {
            printf("WriteToURL error : %s\n", error.description.UTF8String);
        } else {
            printf("analyze sucess! output:%s\n", outputURL.path.UTF8String);
        }
    }
    return 0;
}



