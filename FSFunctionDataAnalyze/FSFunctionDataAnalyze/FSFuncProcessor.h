//
//  FSFuncProcessor.h
//  FSFunctionDataAnalyze
//
//  Created by Kinarobin on 2022/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSFuncProcessor : NSObject

- (instancetype)initWithFunctionRecords:(NSArray *)functionRecords
                            imageSlider:(int64_t)imageSlider
                               dsymPath:(NSString *)dsymPath;

- (NSArray *)process;

@end

NS_ASSUME_NONNULL_END
