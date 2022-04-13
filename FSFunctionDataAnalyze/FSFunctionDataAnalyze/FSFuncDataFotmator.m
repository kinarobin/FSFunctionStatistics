//
//  FSFuncDateFotmator.m
//  FSFunctionDataAnalyze
//
//  Created by Kinarobin on 2022/4/13.
//

#import "FSFuncDataFotmator.h"
#import "FSFuncRecord.h"

@interface FSFuncDataFotmator() {
    NSMutableArray *_currentIndex;
}

@end

@implementation FSFuncDataFotmator

- (instancetype)init {
    if (self = [super init]) {
        _currentIndex = [NSMutableArray array];
    }
    return self;
}

- (NSData *)formatDataWithRecords:(NSArray <FSFuncRecord *>*)records {
    if (records.count == 0) {
        return [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSMutableArray *functionArray = NSMutableArray.array;
    [records enumerateObjectsUsingBlock:^(FSFuncRecord *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *recordInfo = NSMutableDictionary.dictionary;
        recordInfo[@"name"] = obj.symbol;
        recordInfo[@"cost"] = @(obj.cost);
        if (_currentIndex.count == 0) {
            [_currentIndex addObject:@(1)];
        }
        if (idx == 0) {
            recordInfo[@"id"] = self.currentId;
        } else {
            if (obj.level > records[idx - 1].level) {
                recordInfo[@"pid"] = self.currentId;
                [_currentIndex addObject:@(1)];
                recordInfo[@"id"] = self.currentId;
            } else if (obj.level == records[idx - 1].level) {
                
                NSNumber *lastIndex = [_currentIndex lastObject];
                [_currentIndex removeLastObject];
                recordInfo[@"pid"] = self.currentId;
                [_currentIndex addObject:@(lastIndex.intValue + 1)];
                recordInfo[@"id"] = self.currentId;
            } else {
                int num = records[idx - 1].level - obj.level;
                for (int i = 0; i < num; i++) {
                    [_currentIndex removeLastObject];
                }
                
                NSNumber *lastIndex = [_currentIndex lastObject];
                [_currentIndex removeLastObject];
                recordInfo[@"pid"] = self.currentId;
                [_currentIndex addObject:@(lastIndex.intValue + 1)];
                recordInfo[@"id"] = self.currentId;
            }
        }
        [functionArray addObject:recordInfo];
    }];
    NSMutableDictionary *map = NSMutableDictionary.dictionary;
    map[@"code"] = @0;
    map[@"msg"] = @"ok";
    map[@"data"] = functionArray;
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:map options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"FSFuncDataFotmator error:%@", error);
    }
    return data;
}

- (NSString *)currentId {
    NSMutableString *string = [NSMutableString string];
    [_currentIndex enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            [string appendString:obj.stringValue];
        } else {
            [string appendFormat:@"-%@", obj.stringValue];
        }
    }];
    return string;
}

@end
