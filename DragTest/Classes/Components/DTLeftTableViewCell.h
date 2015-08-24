//
//  DTLeftTableViewCell.h
//  DragTest
//
//  Created by xu lingyi on 8/23/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTDragView.h"
#import "DTBigDragView.h"
#import "DTSmallDragView.h"

@protocol DTLeftTableViewCellDelegate;

@interface DTLeftTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UILabel       *name;
@property (strong, nonatomic) UIImageView   *img;

@property (assign, nonatomic) id<DTLeftTableViewCellDelegate>   delegate;

- (void)addDragView;

@end

@protocol DTLeftTableViewCellDelegate <NSObject>

@optional
- (void)buildDrageViewByImage:(UIImage *)image byCenter:(CGPoint)center;

@end
