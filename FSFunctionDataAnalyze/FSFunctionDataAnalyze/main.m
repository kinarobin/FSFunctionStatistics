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
            [NSException raise:@"用法有误！" format:@"argv[0]：需要解析的数据 argv[1]：dsym符号文件 argv[2]：输出的文件"];
        }
        const char *filePath = argv[1];
        const char *symPath = argv[2];
        const char *outputPath = argv[3];
        if (![NSFileManager.defaultManager fileExistsAtPath:@(filePath)]) {
            [NSException raise:@"需要解析的文件不存在" format:@""];
        }
        if (![NSFileManager.defaultManager fileExistsAtPath:@(symPath)]) {
            [NSException raise:@"dsym符号文件不存在" format:@""];
        }
        
        int pointLength = sizeof(void *);
        int int64Length = sizeof(int64_t);
        int int32Length = sizeof(int32_t);
        
        NSData *analyzeData = [NSData dataWithContentsOfFile:@(filePath)];
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
        
        FSFuncProcessor *funcProcessor = [[FSFuncProcessor alloc] initWithFunctionRecords:functionRecords imageSlider:imageSlide dsymPath:@(symPath)];
        NSArray *resules = [funcProcessor process];
        
        FSFuncDataFotmator *dataFotmator = FSFuncDataFotmator.new;
        NSData *data = [dataFotmator formatDataWithRecords:resules];
        
        NSURL *outputURl = [NSURL fileURLWithPath:@(outputPath)];
        NSError *error;
        [data writeToURL:outputURl options:0 error:&error];
        if (error) {
            NSLog(@"WriteToURL error : %@", error);
        } else {
            printf("analyze sucess! output:%s\n", outputPath);
        }
    }
    return 0;
}



