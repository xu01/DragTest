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

@protocol DTDragViewDelegate;

@interface DTDragView : UIView <UIGestureRecognizerDelegate>
{
    BOOL isSmall_;
    
    UIView *_superView;
    
    UIImageView *imageView_;
    
    CGRect startFrame_;
    
    CGPoint startLocation;
    
    BOOL isDragging_;
    
    BOOL isAnimating_;
    
    BOOL isOverEndFrame_;
    
    BOOL isOverBadFrame_;
    
    BOOL isOverStartFrame_;
    
    BOOL isAtEndFrame_;
    
    BOOL isAtStartFrame_;
    
    BOOL canDragFromEndPosition_;
    
    BOOL canSwapToStartPosition_;
    
    BOOL canDragMultipleDragViewsAtOnce_;
    
    BOOL canUseSameEndFrameManyTimes_;
    
    BOOL shouldStickToEndFrame_;
    
    BOOL isAddedToManager_;
    
    NSInteger currentGoodFrameIndex_;
    
    NSInteger currentBadFrameIndex_;
}

// Image
@property (nonatomic, strong) UIImageView *imageView;
// Start Frame
@property (nonatomic) CGRect startFrame;
// Allow Frames
@property (nonatomic, strong) NSArray *allowFramesArray;

@property(nonatomic, assign) id<DTDragViewDelegate> delegate;

@property (nonatomic) BOOL isDragging;
@property (nonatomic) BOOL isOverBadFrame;
@property (nonatomic) BOOL isOverEndFrame;
@property (nonatomic) BOOL isAtEndFrame;
@property (nonatomic) BOOL isAtStartFrame;
@property (nonatomic) BOOL canDragFromEndPosition;

- (id)initWithImage:(UIImage *)image
         startFrame:(CGRect)startFrame
        allowFrames:(NSArray *)allowFrames
        andDelegate:(id<DTDragViewDelegate>)delegate;

- (id)initWithImage:(UIImage *)image
      withSuperView:(UIView *)superView
         startFrame:(CGRect)startFrame
        allowFrames:(NSArray *)allowFrames
        andDelegate:(id<DTDragViewDelegate>)delegate;

@end

@protocol DTDragViewDelegate <NSObject>

@optional
- (void)dragViewDidStartDragging:(DTDragView *)dragView isSmall:(BOOL)isSmall;
- (void)dragViewDidEndDragging:(DTDragView *)dragView;

@end

@interface DragManager : NSObject

+ (DragManager *)manager;

- (void)addDragView:(DTDragView *)dragView;

- (void)removeDragView:(DTDragView *)dragView;

- (BOOL)dragView:(DTDragView*)dragView wantSwapToEndFrame:(CGRect)endFrame;

- (BOOL)dragViewCanStartDragging:(DTDragView*)dragView;

- (void)dragViewDidEndDragging:(DTDragView *)dragView;

- (void)dragView:(DTDragView *)dragView didLeaveEndFrame:(CGRect)endFrame;

@end

@interface OccupancyIndicator : NSObject

@property CGRect frame;
@property NSInteger count;
@property BOOL isFree;

+ (OccupancyIndicator *)indicatorWithFrame:(CGRect)frame;

- (id)initWithFrame:(CGRect)frame;

@end
