//
//  FSFuncRecord.m
//  FSFunctionDataAnalyze
//
//  Created by Kinarobin on 2022/4/13.
//

#import "FSFuncRecord.h"

@implementation FSFuncRecord

- (int64_t)cost {
    return self.end - self.begin;
}

@end
