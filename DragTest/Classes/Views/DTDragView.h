//
//  DTDragView.h
//  DragTest
//
//  Created by xu lingyi on 8/23/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import <UIKit/UIKit.h>

// CGRect to NSValue
NSValue *CGRectValue(CGRect rect);
// NSValue to CGRect
CGRect CGRectFromValue(NSValue *value);

@interface DTDragView : UIView

@end
