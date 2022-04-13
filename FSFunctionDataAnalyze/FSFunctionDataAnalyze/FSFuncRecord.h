//
//  FSFuncRecord.h
//  FSFunctionDataAnalyze
//
//  Created by Kinarobin on 2022/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, FSFunctionState) {
    FSFunctionEnterState,
    FSFunctionExitState,
    FSFunctionFinishedState
};

@interface FSFuncRecord : NSObject

@property (nonatomic, assign) int64_t addr;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int32_t level;
@property (nonatomic, assign) int64_t begin;
@property (nonatomic, assign) int64_t end;
@property (nonatomic, assign) FSFunctionState state;
@property (nonatomic, assign, readonly) int64_t cost;

@end

NS_ASSUME_NONNULL_END
