//
//  CustomGraphView.m
//  CUSTOM GRAPH WITH INTERVAL LIMITS
//
//  Created by Alexandru Nicolae on 18/01/16.
//  Copyright © 2016 Alexandru Nicolae. All rights reserved.
//

#import "CustomGraphView.h"

#define GRAPH_MARGIN 30

@implementation CustomGraphView

+ (id)loadGraphViewWithValuesArray:(NSArray *)valuesArray datesArray:(NSArray *)datesArray rangeArray:(NSArray *)rangeArray valuePointViewsArray:(NSArray *)valuePointViewsArray  periodFrom:(NSDate *)fromDate periodTo:(NSDate *)toDate andFrame:(CGRect)frame
{
    CustomGraphView *customGraphView = [[CustomGraphView alloc]init];
    customGraphView.frame = frame;
    customGraphView.valuesArray = valuesArray;
    customGraphView.datesArray = datesArray;
    customGraphView.rangeArray = rangeArray;
    customGraphView.valuePointViewsArray = valuePointViewsArray;
    customGraphView.fromDate = fromDate;
    customGraphView.toDate = toDate;
    customGraphView.backgroundColor = [UIColor clearColor];
    customGraphView.layer.masksToBounds = YES;
    customGraphView.showGrid = YES;
    [customGraphView setupCustomGraphView];
    return customGraphView;
}

- (void)setupCustomGraphView
{
    [self calculateMinMax];
    [self calculateXYUnits];
    [self calculateXPoints];
    [self calculateYPoints];
    //[self drawGraphLines];
}

- (void)calculateMinMax
{
    int valuesRange = 10;
    if (self.valuesArray.count > 0) {
        self.valuesMin = [self.valuesArray[0]doubleValue] - valuesRange;
        self.valuesMax = [self.valuesArray[0]doubleValue] - valuesRange;
    }
    
    for (int i=0; i<self.valuesArray.count; i++) {
        
        if ([self.valuesArray[i]doubleValue] < self.valuesMin) {
            self.valuesMin = [self.valuesArray[i]doubleValue] - valuesRange;
        }
        if ([self.valuesArray[i]doubleValue] > self.valuesMax) {
            self.valuesMax = [self.valuesArray[i]doubleValue] + valuesRange;
        }
    }
    self.valuesRange = self.valuesMax - self.valuesMin;
    //[self differenceBetweenDates];
}

#pragma mark GET X Y Units
- (void)calculateXYUnits
{
    
    int i = [self.fromDate timeIntervalSince1970];
    int j = [self.toDate timeIntervalSince1970];
    
    double X = j-i;
    self.timelineIntervalInSeconds = X;
    
    
    
    self.graphWidth = self.frame.size.width - 2*GRAPH_MARGIN;
    self.timelineUnit = self.graphWidth/self.timelineIntervalInSeconds;
    
    self.graphHeight = (self.frame.size.height - 2*GRAPH_MARGIN);// + (self.frame.size.height - 2*GRAPH_MARGIN)/10*2;
    self.valuesUnit = self.graphHeight / self.valuesRange;
    //[self calculateYPoints];
}

#pragma mark GET X Points
- (void)calculateXPoints
{
    self.xPointsMutableArray = [@[]mutableCopy];
    [self.datesArray enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL * _Nonnull stop) {
        
        int pointValueInMiliSeconds = [date timeIntervalSince1970];
        int zeroPointValueInMiliSeconds = [self.fromDate timeIntervalSince1970];
        double xPointDouble = (pointValueInMiliSeconds - zeroPointValueInMiliSeconds) * self.timelineUnit;
        NSNumber *xPoint = [NSNumber numberWithDouble:xPointDouble + GRAPH_MARGIN];
        [self.xPointsMutableArray addObject:xPoint];
    }];
}

#pragma mark GET Y Points
- (void)calculateYPoints
{
    self.yPointsMutableArray = [@[]mutableCopy];
    [self.valuesArray enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL * _Nonnull stop) {
        double y = self.frame.size.height - ([value doubleValue] - self.valuesMin) * self.valuesUnit;
        NSNumber *yPoint = [NSNumber numberWithDouble:y - GRAPH_MARGIN];
        [self.yPointsMutableArray addObject:yPoint];
    }];
    
}

#pragma mark GET POINT FOR INDEX
- (CGPoint)getPointForValueAtIndex:(NSUInteger)index
{
    CGPoint point = CGPointMake([[self.xPointsMutableArray objectAtIndex:index] doubleValue], [[self.yPointsMutableArray objectAtIndex:index]doubleValue]);
    return point;
}

#pragma mark DRAW RECT

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self drawGraphAxis];
    [self drawGraphLines];
}

// DRAW GRAPH LINE

- (void)drawGraphLines
{
    int maxDateTimeInterval = [self.toDate timeIntervalSince1970];
    int minDateTimeInterval = [self.fromDate timeIntervalSince1970];
    
    [self.valuesArray enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self drawHorizontalLineForValue:value];
        [self drawVerticalLineForDate:[self.datesArray objectAtIndex:idx]];
        [self drawIntervalsForValueAtIndex:idx];
        int currentDateTimeInterval = [[self.datesArray objectAtIndex:idx]timeIntervalSince1970];

        if (currentDateTimeInterval <= maxDateTimeInterval && currentDateTimeInterval >= minDateTimeInterval) {
            
            if (idx != 0) {
                
                CGPoint lastPoint = [self getPointForValueAtIndex:idx -1];
                CGPoint currentPoint = [self getPointForValueAtIndex:idx];
                
                int currentDateTimeInterval = [[self.datesArray objectAtIndex:idx]timeIntervalSince1970];
                int maxDateTimeInterval = [self.toDate timeIntervalSince1970];
                int minDateTimeInterval = [self.fromDate timeIntervalSince1970];
                if (currentDateTimeInterval <= maxDateTimeInterval && currentDateTimeInterval >= minDateTimeInterval) {
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
                    CGContextSetLineWidth(context, self.frame.size.height/(self.frame.size.height-self.frame.size.height/10));
                    
                    CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
                    CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
                    
                    //Draw it
                    CGContextStrokePath(context);
                    [self drawCirclesOnValuePoints];
                }
            }
            
            
        }
    }];
}

// DRAW CIRCLES OR ADD CUSTOM VIEWS

- (void)drawCirclesOnValuePoints
{
    [self.valuesArray enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL * _Nonnull stop) {
       
        
        //id viewForValue = [self.valuePointViewsArray objectAtIndex:idx];
        int viewWidth = (int)self.frame.size.height/25<10?self.frame.size.height/25:10;
        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewWidth)];
        circleView.backgroundColor = [UIColor blackColor];
        if (idx < self.rangeArray.count) {
            NSDictionary *rangeDict = [self.rangeArray objectAtIndex:idx];
            double rangeLow = [[rangeDict valueForKey:@"low"]doubleValue];
            double rangeHigh = [[rangeDict valueForKey:@"high"]doubleValue];
            if ([value doubleValue] < rangeLow || [value doubleValue] > rangeHigh) {
                circleView.backgroundColor = [UIColor redColor];
            }
        }
        
        circleView.layer.cornerRadius = viewWidth/2;
        circleView.layer.masksToBounds = YES;
        CGPoint valuePoint = [self getPointForValueAtIndex:idx];
        
        circleView.frame = CGRectMake(valuePoint.x-viewWidth/2, valuePoint.y-viewWidth/2, viewWidth, viewWidth);
        [self addSubview:circleView];
    }];
}


//Draw graph axis

- (void)drawGraphAxis
{
    if (self.showGrid) {
        UIView *yAxis = [[UIView alloc]initWithFrame:CGRectMake(GRAPH_MARGIN, GRAPH_MARGIN, 1, self.frame.size.height - 2*GRAPH_MARGIN)];
        yAxis.backgroundColor = [UIColor blackColor];
        yAxis.alpha = 0.2;
        
        UIView *xAxis = [[UIView alloc]initWithFrame:CGRectMake(GRAPH_MARGIN, self.frame.size.height - GRAPH_MARGIN, self.frame.size.width - 2*GRAPH_MARGIN, 1)];
        xAxis.backgroundColor = [UIColor blackColor];
        xAxis.alpha = 0.2;
        
        [self addSubview:xAxis];
        [self addSubview:yAxis];
    }
}

//Draw horizontal line coresponding to value

- (void)drawHorizontalLineForValue:(NSNumber *)value
{
    
    if (self.showGrid) {
        double valueYPoint = self.frame.size.height - ([value doubleValue] - self.valuesMin) * self.valuesUnit;
        
        UIView *horizontalLineView = [[UIView alloc]initWithFrame:CGRectMake(GRAPH_MARGIN, valueYPoint - GRAPH_MARGIN, self.frame.size.width - 2*GRAPH_MARGIN, 1)];
        horizontalLineView.backgroundColor = [UIColor darkGrayColor];
        horizontalLineView.alpha = 0.1;
        
        UILabel *valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, valueYPoint -GRAPH_MARGIN - self.frame.size.height/20, GRAPH_MARGIN, self.frame.size.height/10)];
        valueLabel.minimumScaleFactor = 1;
        valueLabel.font = [UIFont systemFontOfSize:(int)self.frame.size.height/25<10?(int)self.frame.size.height/25:10];
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.text = [value stringValue];
        
        [self addSubview:horizontalLineView];
        [self addSubview:valueLabel];
    }
}

//Draw vertical line for date

- (void)drawVerticalLineForDate:(NSDate *)date
{
    if (self.showGrid) {
        int pointValueInMiliSeconds = [date timeIntervalSince1970];
        int zeroPointValueInMiliSeconds = [self.fromDate timeIntervalSince1970];
        double xPointDouble = (pointValueInMiliSeconds - zeroPointValueInMiliSeconds) * self.timelineUnit;
        
        UIView *verticalLineView = [[UIView alloc]initWithFrame:CGRectMake(xPointDouble + GRAPH_MARGIN, GRAPH_MARGIN, 1, self.frame.size.height - 2*GRAPH_MARGIN)];
        verticalLineView.backgroundColor = [UIColor darkGrayColor];
        verticalLineView.alpha = 0.1;
        
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(xPointDouble + GRAPH_MARGIN - self.frame.size.width/10/2, self.frame.size.height - GRAPH_MARGIN, self.frame.size.width/10, GRAPH_MARGIN)];
        dateLabel.minimumScaleFactor = 1;
        dateLabel.font = [UIFont systemFontOfSize:(int)self.frame.size.width/20<10?(int)self.frame.size.width/20:10];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        dateLabel.text = [dateFormatter stringFromDate:date];
        
        [self addSubview:verticalLineView];
        [self addSubview:dateLabel];
    }
}

//Draw intervals for values at index

- (void)drawIntervalsForValueAtIndex:(NSUInteger)index
{
    if (index < self.rangeArray.count) {
        if ([[self.rangeArray objectAtIndex:index] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *rangeDict = [self.rangeArray objectAtIndex:index];
            double rangeLow = [[rangeDict valueForKey:@"low"]doubleValue];
            double rangeHigh = [[rangeDict valueForKey:@"high"]doubleValue];
            double rangeHeight = (rangeHigh - rangeLow)*self.valuesUnit;
            
            if (index + 1 < self.valuesArray.count) {
                
                CGPoint pointForCurrentIntervalValue = [self getPointForValueAtIndex:index];
                CGPoint pointForNextIntervalValue = [self getPointForValueAtIndex:index + 1];
                double rangeWidth = pointForNextIntervalValue.x - pointForCurrentIntervalValue.x;
                double valueYPoint = self.frame.size.height - (rangeHigh - self.valuesMin) * self.valuesUnit - GRAPH_MARGIN;
                
                if (rangeHeight > 0) {
                    
                    UIView *rangeView = [[UIView alloc]initWithFrame:CGRectMake(pointForCurrentIntervalValue.x, valueYPoint, rangeWidth, rangeHeight)];
                    rangeView.backgroundColor = [UIColor darkGrayColor];
                    rangeView.alpha = 0.1;
                    
                    [self addSubview:rangeView];
                }
            }
        }
    }
}

- (void)setShowGrid:(BOOL)showGrid
{
    if (_showGrid != showGrid) {
        _showGrid = showGrid;
        [self setNeedsDisplay];
    }
}

@end
