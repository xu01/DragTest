//
//  DTMainViewController.h
//  DragTest
//
//  Created by xu lingyi on 8/23/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTLeftTableViewCell.h"
#import "DTDragView.h"
#import "DTBigDragView.h"
#import "DTSmallDragView.h"

@interface DTMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DTDragViewDelegate, DTLeftTableViewCellDelegate>

@property (nonatomic, strong) NSArray *smallTableFrames;
@property (nonatomic, strong) NSArray *bigTableFrames;

@end
