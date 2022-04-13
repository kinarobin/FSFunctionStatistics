//
//  FSFuncTranslator.m
//  FSFunctionDataAnalyze
//
//  Created by Kinarobin on 2022/4/13.
//

#import "FSFuncTranslator.h"
#import "FSSystemCmd.h"

@interface FSFuncTranslator()

@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, assign) int64_t loadAddress;

@end

@implementation FSFuncTranslator

- (instancetype)initWithloadAddress:(int64_t)loadAddress
                           dsymPath:(NSString *)dsymPath {
    if (self = [super init]) {
        _loadAddress = loadAddress;
        _addressCache = [NSMutableDictionary dictionary];
        self.symbol = dsymPath;
    }
    return self;
}

- (void)setSymbol:(NSString *)symbol {
    NSString *symbolDir = [symbol stringByAppendingPathComponent:@"Contents/Resources/DWARF/"];
    _symbol = [self firstLevelFilesInDirectory:symbolDir].firstObject;
}

- (NSArray *)firstLevelFilesInDirectory:(NSString *)dir {
    NSMutableArray *files = [NSMutableArray array];
    NSError *error;
    NSArray *filesInDir = [NSFileManager.defaultManager contentsOfDirectoryAtPath:dir error:&error];
    if (error) {
        NSLog(@"FSFuncTranslator error:%@", error);
        return nil;
    }
    for (NSString *fileName in filesInDir) {
        BOOL isDir = NO;
        NSString *filePath = [dir stringByAppendingPathComponent:fileName];
        if ([NSFileManager.defaultManager fileExistsAtPath:filePath isDirectory:&isDir]) {
            if (!isDir) {
                [files addObject:filePath];
            }
        }
    }
    return files;
}

- (void)addFuncAddress:(int64_t)address {
    if (_addressCache[@(address)] == nil) {
        _addressCache[@(address)] = @"";
    }
}

- (void)translate {
    if (_addressCache.allKeys.count == 0) {
        return;
    }
    NSArray *addressArray = _addressCache.allKeys.copy;
    NSUInteger beginIndex = 0;
    NSUInteger maxAddrCount = 1000;
    while (beginIndex < addressArray.count) {
        NSUInteger endIndex = (beginIndex + maxAddrCount) > addressArray.count ? addressArray.count : beginIndex + maxAddrCount;
        NSArray *subAddrArray = [addressArray subarrayWithRange:NSMakeRange(beginIndex, endIndex - beginIndex)];
        NSString *cmdString = [self translateCmd:subAddrArray];
        
        NSArray *transCmdArray = [cmdString componentsSeparatedByString:@" "];
        printf("atos 开始解析...\n");
        FSSystemCmd *systemCmd = [FSSystemCmd exec:transCmdArray];
        printf("atos 解析完毕\n");
        if (systemCmd.errString.length > 0 || systemCmd.terminationStatus != 0) {
            [NSException raise:@"atos 解析失败" format:@""];
        }
        NSArray *symbolsArray = [systemCmd.outputString componentsSeparatedByString:@"\n"];
        [subAddrArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            _addressCache[obj] = symbolsArray[idx];
        }];
        beginIndex += maxAddrCount;
    }
}

- (NSString *)translateCmd:(NSArray *)addressArray {
    if (_symbol.length == 0 || _loadAddress == 0 || _addressCache.count == 0) {
        [NSException raise:@"FSFuncTranslator translateCmd error" format:@""];;
    }
    printf("image header address:%p\n", (void *)_loadAddress);
    NSString *loadAddrString = [NSString stringWithFormat:@"%p ", (void *)_loadAddress];
    NSMutableString *transCmd = [NSMutableString stringWithFormat:@"atos -o %@ -l %@", _symbol, loadAddrString];
    for (NSNumber *address in addressArray) {
        [transCmd appendFormat:@"%p ", (void *)address.integerValue];
    }
    return transCmd;
}
@end
