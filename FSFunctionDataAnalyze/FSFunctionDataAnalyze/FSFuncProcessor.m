//
//  FSFuncProcessor.m
//  FSFunctionDataAnalyze
//
//  Created by Kinarobin on 2022/4/13.
//

#import "FSFuncProcessor.h"
#import "FSFuncTranslator.h"
#import "FSFuncRecord.h"

@interface FSFuncProcessor()

@property (nonatomic, copy) NSArray <FSFuncRecord *> *functionRecords;
@property (nonatomic, assign) int64_t imageSlider;
@property (nonatomic, strong) FSFuncTranslator *funcTranslator;

@end

@implementation FSFuncProcessor

- (instancetype)initWithFunctionRecords:(NSArray *)functionRecords
                            imageSlider:(int64_t)imageSlider
                               dsymPath:(NSString *)dsymPath {
    if (self = [super init]) {
        _functionRecords = functionRecords;
        _imageSlider = imageSlider;
        _funcTranslator = [[FSFuncTranslator alloc] initWithloadAddress:imageSlider dsymPath:dsymPath];
    }
    return self;
}

- (NSArray *)process {
    if (_functionRecords.count == 0) {
        return @[];
    }
    [self translate];
    int64_t beginTime = _functionRecords.firstObject.begin;
    int64_t endTime = _functionRecords.lastObject.end == 0 ? _functionRecords.lastObject.begin : _functionRecords.lastObject.end;
    NSMutableArray <FSFuncRecord *> *recordsMerged = NSMutableArray.array;
    int minLevel = 1;
    for (FSFuncRecord *record in _functionRecords) {
        if (minLevel > record.level) {
            minLevel = record.level;
        }
    }
    __block int normalLevel = 0;
    [_functionRecords enumerateObjectsUsingBlock:^(FSFuncRecord * _Nonnull record, NSUInteger idx, BOOL * _Nonnull stop) {
        record.level -=  minLevel;
        if (record.state == FSFunctionEnterState) {
            [recordsMerged addObject:record];
        }
        if (record.state == FSFunctionExitState) {
            __block BOOL match = NO;
            [recordsMerged enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(FSFuncRecord *beforeRecord, NSUInteger idx, BOOL * _Nonnull stop) {
                if (beforeRecord.addr == record.addr && beforeRecord.state == FSFunctionEnterState) {
                    beforeRecord.state = FSFunctionFinishedState;
                    beforeRecord.end = record.end;
                    normalLevel -= 1;
                    match = YES;
                    *stop = YES;
                }
            }];
            if (!match) {
                record.state = FSFunctionFinishedState;
                record.begin = beginTime;
                [recordsMerged insertObject:record atIndex:0];
            }
        }
    }];
    
    for (FSFuncRecord * record in recordsMerged) {
        if (record.state == FSFunctionEnterState) {
            record.state = FSFunctionFinishedState;
            record.end = endTime;
        }
        record.symbol = _funcTranslator.addressCache[@(record.addr)];
    }
    printf("record had merged!\n");
    
    return recordsMerged;
}

- (void)translate {
    for (FSFuncRecord *record in _functionRecords) {
        [_funcTranslator addFuncAddress:record.addr];
    }
    [_funcTranslator translate];
}

@end
