//
//  CustomGraphView.h
//  CUSTOM GRAPH WITH INTERVAL LIMITS
//
//  Created by Alexandru Nicolae on 18/01/16.
//  Copyright © 2016 Alexandru Nicolae. All rights reserved.
//

//*************************
//README

//Load the graph with the same number of values and dates.
//For rangeArray create an array of dictionaries with NSNumbers like: @[@{@"low": @17, @"high": @36}]

//*************************

 
#import <UIKit/UIKit.h>

@interface CustomGraphView : UIView

@property (nonatomic, strong) NSArray *valuesArray;
@property (nonatomic, strong) NSArray *datesArray;
@property (nonatomic, strong) NSArray *rangeArray;
@property (nonatomic, strong) NSArray *valuePointViewsArray;
@property (nonatomic, strong) NSArray *valuePointsCoordinatesArray;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSMutableArray *xPointsMutableArray;
@property (nonatomic, strong) NSMutableArray *yPointsMutableArray;

@property (nonatomic) double valuesMin;
@property (nonatomic) double valuesMax;
@property (nonatomic) double valuesRange;
@property (nonatomic) double graphWidth;
@property (nonatomic) double graphHeight;
@property (nonatomic) double timelineUnit;
@property (nonatomic) double valuesUnit;
@property (nonatomic) int timelineIntervalInSeconds;
@property (nonatomic) BOOL showGrid;


+ (id)loadGraphViewWithValuesArray:(NSArray *)valuesArray datesArray:(NSArray *)datesArray rangeArray:(NSArray *)rangeArray valuePointViewsArray:(NSArray *)valuePointViewsArray  periodFrom:(NSDate *)fromDate periodTo:(NSDate *)toDate andFrame:(CGRect)frame;

@end
