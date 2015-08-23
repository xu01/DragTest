//
//  DTDragView.m
//  DragTest
//
//  Created by xu lingyi on 8/23/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import "DTDragView.h"

NSValue *CGRectValue(CGRect rect){
    return [NSValue valueWithCGRect:rect];
}
CGRect CGRectFromValue(NSValue *value){
    return [value CGRectValue];
}

@implementation DTDragView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
