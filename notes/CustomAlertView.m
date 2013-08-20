//
//  CustomAlertView.m
//  CustomAlert
//
//  Created by Aaron Crabtree on 10/14/11.
//  Copyright (c) 2011 Tap Dezign, LLC. All rights reserved.
//

#import "CustomAlertView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomAlertView

#pragma mark -
#pragma mark Memory management


#pragma mark -
#pragma mark UIView Overrides

@synthesize passwordIsAccepted;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        passwordIsAccepted = NO;
    }
    return self;
}

- (void)layoutSubviews
{
	for (UIView *subview in self.subviews)
    {
		if ([subview isMemberOfClass:[UIImageView class]])
        {
			subview.hidden = YES;
		}
        
		if ([subview isMemberOfClass:[UILabel class]])
        {
			UILabel *label = (UILabel*)subview;
            
			label.textColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f];
			label.shadowColor = [UIColor blackColor];
			label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		}
	}
}

- (void)drawRect:(CGRect)rect 
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGRect activeBounds = self.bounds;
	CGFloat cornerRadius = 10.0f;	
	CGFloat inset = 6.5f;	
	CGFloat originX = activeBounds.origin.x + inset;
	CGFloat originY = activeBounds.origin.y + inset;
	CGFloat width = activeBounds.size.width - (inset*2.0f);
	CGFloat height = activeBounds.size.height - (inset*2.0f);
    
	CGRect bPathFrame = CGRectMake(originX, originY, width, height);
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:bPathFrame cornerRadius:cornerRadius].CGPath;
	
	CGContextAddPath(context, path);
	CGContextSetFillColorWithColor(context, [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 6.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor);
    CGContextDrawPath(context, kCGPathFill);
	
	CGContextSaveGState(context);
	CGContextAddPath(context, path);
	CGContextClip(context);
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	size_t count = 3;
	CGFloat locations[3] = {0.0f, 0.57f, 1.0f}; 
	CGFloat components[12] = 
	{	70.0f/255.0f, 70.0f/255.0f, 70.0f/255.0f, 1.0f,
		55.0f/255.0f, 55.0f/255.0f, 55.0f/255.0f, 1.0f,
		40.0f/255.0f, 40.0f/255.0f, 40.0f/255.0f, 1.0f};
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, count);
    
	CGPoint startPoint = CGPointMake(activeBounds.size.width * 0.5f, 0.0f);
	CGPoint endPoint = CGPointMake(activeBounds.size.width * 0.5f, activeBounds.size.height);
    
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGColorSpaceRelease(colorSpace);
	CGGradientRelease(gradient);
	
    CGFloat buttonOffset = 92.5f;
	CGContextSaveGState(context);
	CGRect hatchFrame = CGRectMake(0.0f, buttonOffset-44, activeBounds.size.width, (activeBounds.size.height - buttonOffset+1.0f)+44);
	CGContextClipToRect(context, hatchFrame);
	
	CGFloat spacer = 4.0f;
	int rows = (activeBounds.size.width + activeBounds.size.height/spacer);
	CGFloat padding = 0.0f;
	CGMutablePathRef hatchPath = CGPathCreateMutable();
	for(int i=1; i<=rows; i++) {
		CGPathMoveToPoint(hatchPath, NULL, spacer * i, padding);
		CGPathAddLineToPoint(hatchPath, NULL, padding, spacer * i);
	}
	CGContextAddPath(context, hatchPath);
	CGPathRelease(hatchPath);
	CGContextSetLineWidth(context, 1.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.15f].CGColor);
	CGContextDrawPath(context, kCGPathStroke);
	CGContextRestoreGState(context);
	
	CGMutablePathRef linePath = CGPathCreateMutable(); 
	CGFloat linePathY = (buttonOffset - 1.0f);
	CGPathMoveToPoint(linePath, NULL, 0.0f, linePathY-45);
	CGPathAddLineToPoint(linePath, NULL, activeBounds.size.width, linePathY-45);
	CGContextAddPath(context, linePath);
	CGPathRelease(linePath);
	CGContextSetLineWidth(context, 1.0f);
	CGContextSaveGState(context);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.6f].CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 0.0f, [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.2f].CGColor);
	CGContextDrawPath(context, kCGPathStroke);
	CGContextRestoreGState(context);
	
	CGContextAddPath(context, path);
	CGContextSetLineWidth(context, 3.0f);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 6.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor);
	CGContextDrawPath(context, kCGPathStroke);
    

    CGContextRestoreGState(context);
	CGContextAddPath(context, path);
	CGContextSetLineWidth(context, 3.0f);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 0.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.1f].CGColor);
	CGContextDrawPath(context, kCGPathStroke);
	
}

-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if ((buttonIndex == 1) && (!passwordIsAccepted))
    {
        [self shakeView];
        return;
    }
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

-(void)shakeView
{
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.1];
    [shake setRepeatCount:2];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(self.center.x + 5,self.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(self.center.x - 5, self.center.y)]];
    [self.layer addAnimation:shake forKey:@"position"];
}

@end

