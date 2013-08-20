//  DetectorView.m
//  notes
//
//  Created by Oleg Sobolev on 11.08.13.
//  Copyright (c) 2013 gg. All rights reserved.
//

#import "DetectorView.h"

@implementation DetectorView

@synthesize countOfSectors;

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    switch (countOfSectors)
    {
        case 0:
            [self setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
            break;
        case 1:
            [self drawOneSector];
            break;
        case 2:
            [self drawTwoSectors];
            break;
        case 3:
            [self drawThreeSectors];
            break;
    }
}

-(void)fillRect:(CGRect)rect withGradientColors:(CGFloat[])colors byPointsCount:(int)count
{
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, count);
    //CGGradientCreateWithColorComponents(baseSpace, colors, NULL, count);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);

    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(context);
    
    CGContextAddEllipseInRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
}

-(void)drawOneSector
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor groupTableViewBackgroundColor] set];
    CGContextFillRect(context, self.frame);
    
    CGRect frameToDraw = self.frame;
    frameToDraw.origin.x = 0;
    frameToDraw.size.width = self.frame.size.width / 3;

    CGFloat colors [] = {
                1.0, 1.0, 1.0, 1.0,
                1.0, 0.0, 0.0, 1.0,
                1.0, 1.0, 1.0, 1.0,
            };

    [self fillRect:frameToDraw withGradientColors:colors byPointsCount:3];

}

-(void)drawTwoSectors
{
    [self drawOneSector];
    
    CGRect frameToDraw = self.frame;
    frameToDraw.size.width = self.frame.size.width / 3;
    frameToDraw.origin.x = frameToDraw.size.width;
    
    CGFloat colors [] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 0.0, 1.0,
        1.0, 1.0, 1.0, 1.0,
    };

    [self fillRect:frameToDraw withGradientColors:colors byPointsCount:3];
}

-(void)drawThreeSectors
{
    [self drawTwoSectors];
    
    CGRect frameToDraw = self.frame;
    frameToDraw.size.width = self.frame.size.width/3;
    frameToDraw.origin.x = frameToDraw.size.width*2;
    
    CGFloat colors [] = {
        1.0, 1.0, 1.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        1.0, 1.0, 1.0, 1.0,
    };

    [self fillRect:frameToDraw withGradientColors:colors byPointsCount:3];
}
@end
