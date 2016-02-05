//
//  ViewController.m
//  CustomGraphTest
//
//  Created by ALEXANDRUN-MAC on 05/02/16.
//  Copyright © 2016 AlexandruNicolae. All rights reserved.
//

#import "ViewController.h"
#import "CustomGraphView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *valuesArray = @[@12, @20, @60, @41, @30, @12, @20];
    NSMutableArray *rangeArray = [@[]mutableCopy];
    NSMutableArray *datesArray = [@[]mutableCopy];
    NSDate *today = [[NSDate date] dateByAddingTimeInterval:-3600*24*10];
    __block NSDate *lastDate = nil;
    [valuesArray enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            [datesArray addObject:today];
            lastDate = today;
        } else {
            if (idx%2==0) {
                lastDate = [lastDate dateByAddingTimeInterval:3600*12*idx];
            } else {
                lastDate = [lastDate dateByAddingTimeInterval:3600*36*idx];
            }
            [datesArray addObject:lastDate];
        }
        [rangeArray addObject:@{@"low": @20, @"high": @30}];
    }];
    
    CustomGraphView *customGraphView = [CustomGraphView loadGraphViewWithValuesArray:valuesArray datesArray:datesArray rangeArray:rangeArray valuePointViewsArray:nil periodFrom:today periodTo:[today dateByAddingTimeInterval:3600*24*30] andFrame:CGRectMake(0, 200, self.view.frame.size.width, 250)];
    //customGraphView.showGrid = NO;
    [self.view addSubview:customGraphView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
