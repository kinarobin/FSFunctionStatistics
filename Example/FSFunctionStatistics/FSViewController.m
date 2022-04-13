//
//  FSViewController.m
//  FSFunctionStatistics
//
//  Created by kinarobin on 04/12/2022.
//  Copyright (c) 2022 kinarobin. All rights reserved.
//

#import "FSViewController.h"
#import <FSFunctionStatistics/FSFunctionProfierInterface.h>

@implementation FSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    [self sleep];
    
    stopProfiler();
}

- (void)sleep {
    sleep(2);
}

@end
