//
//  FSFuncTranslator.h
//  FSFunctionDataAnalyze
//
//  Created by Kinarobin on 2022/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSFuncTranslator : NSObject

- (instancetype)initWithloadAddress:(int64_t)loadAddress
                           dsymPath:(NSString *)dsymPath;

- (void)addFuncAddress:(int64_t)address;
- (void)translate;

@property (nonatomic, strong) NSMutableDictionary *addressCache;

@end

NS_ASSUME_NONNULL_END
