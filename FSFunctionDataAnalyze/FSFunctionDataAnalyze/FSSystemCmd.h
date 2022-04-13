//
//  FSSystemCmd.h
//  FSFunctionDataAnalyze
//
//  Created by Kinarobin on 2022/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSSystemCmd : NSObject

@property (nonatomic, copy) NSString *outputString;
@property (nonatomic, copy) NSString *errString;
@property (nonatomic, assign) int terminationStatus;

+ (FSSystemCmd *)exec:(NSArray *)cmd;

@end

NS_ASSUME_NONNULL_END
