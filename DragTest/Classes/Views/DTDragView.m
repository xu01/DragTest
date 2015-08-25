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

- (id)initWithImage:(UIImage *)image
      withSuperView:(UIView *)superView
         startFrame:(CGRect)startFrame
        allowFrames:(NSArray *)allowFrames
        andDelegate:(id<DTDragViewDelegate>)delegate {
    self = [self initWithImage:image startFrame:startFrame allowFrames:allowFrames andDelegate:delegate];
    if (!self) return nil;
    _superView = superView;
    return self;
}

- (id)initWithImage:(UIImage *)image
         startFrame:(CGRect)startFrame
        allowFrames:(NSArray *)allowFrames
        andDelegate:(id<DTDragViewDelegate>) delegate{
    
    self = [super initWithFrame:startFrame];
    
    if(!self) return nil;
    
    self.allowFramesArray = allowFrames;
    
    self.startFrame = startFrame;
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.imageView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.imageView setImage:image];
    [self addSubview:self.imageView];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    [panGesture setMaximumNumberOfTouches:2];
    panGesture.delaysTouchesEnded = NO;
    [panGesture setDelegate:self];
    [self addGestureRecognizer:panGesture];
    
    self.userInteractionEnabled = YES;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.exclusiveTouch = NO;
    self.multipleTouchEnabled = NO;
    
    //self.usedVelocity = kTKDragConstantTime;
    self.isDragging =       NO;
    self.isOverBadFrame =   NO;
    self.isOverEndFrame =   NO;
    self.isAtEndFrame =     NO;
    self.isAtStartFrame =   YES;
    self.canDragFromEndPosition = YES;
    
    canUseSameEndFrameManyTimes_ = YES;
    canDragMultipleDragViewsAtOnce_ = YES;
    
    canSwapToStartPosition_ = YES;
    isOverStartFrame_ = YES;
    
    isAddedToManager_ = NO;
    
    currentBadFrameIndex_ = currentGoodFrameIndex_ = -1;
    
    startLocation = CGPointZero;
    
    self.delegate = delegate;
    
    return self;
}

- (void)panDetected:(UIPanGestureRecognizer*)gestureRecognizer{
    switch ([gestureRecognizer state]) {
        case UIGestureRecognizerStateBegan:
            [self panBegan:gestureRecognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self panMoved:gestureRecognizer];
            break;
        case UIGestureRecognizerStateEnded:
            [self panEnded:gestureRecognizer];
            break;
        default:
            break;
    }
}

- (void)panBegan:(UIPanGestureRecognizer*)gestureRecognizer{
    
    if (!isDragging_) {
        
        self.layer.borderColor = [[UIColor redColor] CGColor];
        self.layer.borderWidth = 1.0;
        
        isDragging_ = YES;
        
        CGPoint pt = [gestureRecognizer locationInView:self.superview];
        
        startLocation = pt;
        
        [[self superview] bringSubviewToFront:self];
        
        SEL dragViewDidStartDragging = @selector(dragViewDidStartDragging:isSmall:);
        
        if(self.delegate && [(NSObject *)self.delegate respondsToSelector:dragViewDidStartDragging]){
            //if (isSmall_) {
                [self.delegate dragViewDidStartDragging:self isSmall:YES];
            //} else {
                //[self.delegate dragViewDidStartDragging:self isSmall:NO];
            //}
        }
    }
}

- (void)panMoved:(UIPanGestureRecognizer*)gestureRecognizer{
    
    if(!isDragging_)
        return;
    
    if (![[self superview] isKindOfClass:[UIScrollView class]]) {
        if (CGRectContainsPoint(_superView.frame, self.frame.origin)) {
            self.frame = CGRectMake(self.frame.origin.x-_superView.frame.origin.x, self.frame.origin.y-_superView.frame.origin.y, self.frame.size.width, self.frame.size.height);
            [_superView addSubview:self];
        }
    }
    
    // 四种超出边界
    CGPoint selfOrigin = [self convertPoint:self.frame.origin toView:[self superview]];
    NSLog(@"x:%f - y:%f", selfOrigin.x, selfOrigin.y);
    if (selfOrigin.x < 0) {
        self.frame = CGRectMake(0.0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    if (selfOrigin.y < 0) {
        self.frame = CGRectMake(self.frame.origin.x, 0.0, self.frame.size.width, self.frame.size.height);
    }
    if (selfOrigin.x+self.frame.size.width > kWidth*(kColumns-1)*2) {
        self.frame = CGRectMake(kWidth*kColumns-self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    if (selfOrigin.y+self.frame.size.width > kWidth*(kColumns-1)*2) {
        self.frame = CGRectMake(self.frame.origin.x, kWidth*kColumns-self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }
    
    CGPoint pt = [gestureRecognizer locationInView:self];
    CGPoint translation = [gestureRecognizer translationInView:[self superview]];
    [self setCenter:CGPointMake([self center].x + translation.x, [self center].y + translation.y)];
    [gestureRecognizer setTranslation:CGPointZero inView:[self superview]];
    
    // Is over start frame
    
    BOOL isOverStartFrame = [self didEnterStartFrameWithPoint:pt];
    
    if (!isOverStartFrame_ && isOverStartFrame) {
        
        /*if (delegateFlags_.dragViewDidEnterStartFrame)
         [self.delegate dragViewDidEnterStartFrame:self];
         isOverStartFrame_ = YES;*/
    }
    else if(isOverStartFrame_ && !isOverStartFrame){
        
        /*if (delegateFlags_.dragViewDidLeaveStartFrame)
         [self.delegate dragViewDidLeaveStartFrame:self];
         isOverStartFrame_ = NO;*/
    }
    
    
    
    // Is over good or bad frame?
    
    NSInteger goodFrameIndex = [self goodFrameIndexWithPoint:pt];
    NSInteger badFrameIndex = [self badFrameIndexWithPoint:pt];
    
    
    // Entered new good frame
    if (goodFrameIndex >= 0 && !isOverEndFrame_) {
        
        /*if (delegateFlags_.dragViewDidEnterGoodFrame) {
         [self.delegate dragViewDidEnterGoodFrame:self atIndex:goodFrameIndex];
         }*/
        
        currentGoodFrameIndex_ = goodFrameIndex;
        isOverEndFrame_ = YES;
    }
    
    
    // Did leave good frame
    if (isOverEndFrame_ && goodFrameIndex < 0) {
        
        /*if (delegateFlags_.dragViewDidLeaveGoodFrame) {
         [self.delegate dragViewDidLeaveGoodFrame:self atIndex:currentGoodFrameIndex_];
         
         }*/
        
        /*if(!canUseSameEndFrameManyTimes_){
         CGRect allowFrame = CGRectFromValue([self.allowFramesArray objectAtIndex:currentGoodFrameIndex_]);
         [[TKDragManager manager] dragView:self didLeaveEndFrame:allowFrame];
         }*/
        
        currentGoodFrameIndex_ = -1;
        isOverEndFrame_ = NO;
        isAtEndFrame_ = NO;
        
    }
    
    // Did switch from one good from to another
    
    if (isOverEndFrame_ && goodFrameIndex != currentGoodFrameIndex_) {
        
        /*if (delegateFlags_.dragViewDidLeaveGoodFrame) {
         [self.delegate dragViewDidLeaveGoodFrame:self atIndex:currentGoodFrameIndex_];
         
         }
         
         if (!canUseSameEndFrameManyTimes_ && isAtEndFrame_) {
         CGRect rect = TKCGRectFromValue([self.goodFramesArray objectAtIndex:currentGoodFrameIndex_]);
         [[TKDragManager manager] dragView:self didLeaveEndFrame:rect];
         }
         
         if (delegateFlags_.dragViewDidEnterGoodFrame) {
         [self.delegate dragViewDidEnterGoodFrame:self atIndex:goodFrameIndex];
         }*/
        
        currentGoodFrameIndex_ = goodFrameIndex;
        isAtEndFrame_ = NO;
    }
    
    
    // Is over bad frame
    
    if(badFrameIndex >= 0 && !isOverBadFrame_) {
        
        /*if (delegateFlags_.dragViewDidEnterBadFrame)
         [self.delegate dragViewDidEnterBadFrame:self atIndex:badFrameIndex];
         
         isOverBadFrame_ = YES;
         currentBadFrameIndex_ = badFrameIndex;*/
    }
    
    if (isOverBadFrame_ && badFrameIndex < 0) {
        /*if (delegateFlags_.dragViewDidLeaveBadFrame)
         [self.delegate dragViewDidLeaveBadFrame:self atIndex:currentBadFrameIndex_];
         
         isOverBadFrame_ = NO;
         currentBadFrameIndex_ = -1;*/
    }
    
    
    // Did switch bad frames
    if (isOverBadFrame_ && badFrameIndex != currentBadFrameIndex_){
        /*if (delegateFlags_.dragViewDidLeaveBadFrame)
         [self.delegate dragViewDidLeaveBadFrame:self atIndex:currentBadFrameIndex_];
         
         if (delegateFlags_.dragViewDidEnterBadFrame)
         [self.delegate dragViewDidEnterBadFrame:self atIndex:badFrameIndex];
         
         currentBadFrameIndex_ = badFrameIndex;*/
        
    }
    
}

- (void)panEnded:(UIPanGestureRecognizer*)gestureRecognizer{
    
    if (!isDragging_)
        return;
    
    self.layer.borderWidth = 0.0;
    
    isDragging_ = NO;
    
    // 四种超出边界
    CGPoint selfOrigin = [self convertPoint:self.frame.origin toView:[self superview]];
    NSLog(@"x:%f - y:%f", selfOrigin.x, selfOrigin.y);
    if (selfOrigin.x < 0) {
        self.frame = CGRectMake(0.0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    if (selfOrigin.y < 0) {
        self.frame = CGRectMake(self.frame.origin.x, 0.0, self.frame.size.width, self.frame.size.height);
    }
    if (selfOrigin.x+self.frame.size.width > kWidth*(kColumns-1)*2) {
        self.frame = CGRectMake(kWidth*kColumns-self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    if (selfOrigin.y+self.frame.size.width > kWidth*(kColumns-1)*2) {
        self.frame = CGRectMake(self.frame.origin.x, kWidth*kColumns-self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }
    
    if(!canDragMultipleDragViewsAtOnce_)
        //[[TKDragManager manager] dragViewDidEndDragging:self];
        
        //if (delegateFlags_.dragViewDidEndDragging) {
        //[self.delegate dragViewDidEndDragging:self];
        //}
        
        //if (delegateFlags_.dragViewCanAnimateToEndFrame){
        //if (![self.delegate dragView:self canAnimateToEndFrameWithIndex:currentGoodFrameIndex_]){
        //[self swapToStartPosition];
        //return;
        //}
        //}
        
        if (isOverBadFrame_) {
            //if (delegateFlags_.dragViewDidLeaveBadFrame)
            //[self.delegate dragViewDidLeaveBadFrame:self atIndex:currentBadFrameIndex_];
        }
    
    
    if (isAtEndFrame_ && !shouldStickToEndFrame_) {
        if(!canUseSameEndFrameManyTimes_) {
            CGRect allowFrame = CGRectFromValue([self.allowFramesArray objectAtIndex:currentGoodFrameIndex_]);
            [[DragManager manager] dragView:self didLeaveEndFrame:allowFrame];
        }
        
        //if(delegateFlags_.dragViewDidLeaveGoodFrame)
        //[self.delegate dragViewDidLeaveGoodFrame:self atIndex:currentGoodFrameIndex_];
        
        //[self swapToStartPosition];
    }
    else{
        //if (isOverStartFrame_ && canSwapToStartPosition_) {
        //[self swapToStartPosition];
        //}
        //else{
        
        if (currentGoodFrameIndex_ >= 0) {
            [self swapToEndPositionAtIndex:currentGoodFrameIndex_];
        }
        else{
            if (isOverEndFrame_ && !canUseSameEndFrameManyTimes_) {
                //CGRect goodFrame = TKCGRectFromValue([self.goodFramesArray objectAtIndex:currentGoodFrameIndex_]);
                //[[TKDragManager manager] dragView:self didLeaveEndFrame:goodFrame];
            }
            
            //[self swapToStartPosition];
        }
        //}
    }
    
    startLocation = CGPointZero;
}

#pragma mark - Private

- (BOOL)didEnterGoodFrameWithPoint:(CGPoint)point {
    
    if ([self goodFrameIndexWithPoint:point] >= 0) {
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL)didEnterBadFrameWithPoint:(CGPoint)point {
    
    if ([self badFrameIndexWithPoint:point] >= 0) {
        return YES;
    }
    else{
        return NO;
    }
    
}

- (BOOL)didEnterStartFrameWithPoint:(CGPoint)point {
    
    CGPoint touchInSuperview = [self convertPoint:point toView:[self superview]];
    
    return CGRectContainsPoint(startFrame_,touchInSuperview);
}

- (NSInteger)badFrameIndexWithPoint:(CGPoint)point{
    
    CGPoint touchInSuperview = [self convertPoint:point toView:[self superview]];
    
    NSInteger index = -1;
    
    
    
    //for (int i=0;i<[self.badFramesArray count];i++) {
    // CGRect badFrame = [[self.badFramesArray objectAtIndex:i] CGRectValue];
    //if (CGRectContainsPoint(badFrame, touchInSuperview))
    //index = i;
    //}
    
    
    return index;
}

- (NSInteger)goodFrameIndexWithPoint:(CGPoint)point{
    
    NSInteger index = -1;
    //CGPoint touchInSuperview = [self convertPoint:point toView:[self superview]];
    CGPoint center = self.center;
    
    /*for (int i=0;i<[self.allowFramesArray count];i++) {
     CGRect goodFrame = [[self.allowFramesArray objectAtIndex:i] CGRectValue];
     if (CGRectContainsPoint(goodFrame, center)) {
     index = i;
     break;
     }
     }*/
    
    for (int i=0; i<[self.allowFramesArray count]; i++) {
        CGRect goodFrame = [[self.allowFramesArray objectAtIndex:i] CGRectValue];
        if (CGRectContainsPoint(goodFrame, center)) {
            //左上自动对齐
            if ((self.frame.origin.x-goodFrame.origin.x) <= (kWidth/2) && 0 <= (self.frame.origin.x-goodFrame.origin.x)
                && (self.frame.origin.y-goodFrame.origin.y) <= (kWidth/2) && 0 <= (self.frame.origin.y-goodFrame.origin.y)) {
                index = i;
                break;
            }
            //右上自动对齐
            else if ((goodFrame.origin.x-self.frame.origin.x) <= (kWidth/2) && 0 <= (goodFrame.origin.x-self.frame.origin.x)
                     && (self.frame.origin.y-goodFrame.origin.y) <= (kWidth/2) && 0 <= (self.frame.origin.y-goodFrame.origin.y)) {
                index = i;
                break;
            }
            //左下自动对齐
            else if ((self.frame.origin.x-goodFrame.origin.x) <= (kWidth/2) && 0 <= (self.frame.origin.x-goodFrame.origin.x)
                     && (goodFrame.origin.y-self.frame.origin.y) <= (kWidth/2) && 0 <= (goodFrame.origin.y-self.frame.origin.y)) {
                index = i;
                break;
            }
            //右下自动对齐
            else if ((goodFrame.origin.x-self.frame.origin.x) <= (kWidth/2) && 0 <= (goodFrame.origin.x-self.frame.origin.x)
                     && (goodFrame.origin.y-self.frame.origin.y) <= (kWidth/2) && 0 <= (goodFrame.origin.y-self.frame.origin.y)) {
                index = i;
                break;
            }
            /*//上下边缘左对齐
             else if ((self.frame.origin.x-goodFrame.origin.x) <= (kWidth/2) && 0 <= (self.frame.origin.x-goodFrame.origin.x)) {
             index = i;
             break;
             }
             //上下边缘右对齐
             else if ((goodFrame.origin.x-self.frame.origin.x) <= (kWidth/2) && 0 <= (goodFrame.origin.x-self.frame.origin.x)) {
             index = i;
             break;
             }
             //左右边缘上对齐
             else if ((self.frame.origin.y-goodFrame.origin.y) <= (kWidth/2) && 0 <= (self.frame.origin.y-goodFrame.origin.y)) {
             index = i;
             break;
             }
             //左右边缘下对齐
             else if ((goodFrame.origin.y-self.frame.origin.y) <= (kWidth/2) && 0 <= (goodFrame.origin.y-self.frame.origin.y)) {
             index = i;
             break;
             }*/
        }
    }
    return index;
}

#pragma mark - Public

- (void)swapToStartPosition{
    
    isAnimating_ = YES;
    
    //if (delegateFlags_.dragViewWillSwapToStartFrame)
    //[self.delegate dragViewWillSwapToStartFrame:self];
    
    
    NSLog(@"back to start");
    /*[UIView animateWithDuration:[self swapToStartAnimationDuration]
     delay:0.
     options:UIViewAnimationOptionCurveEaseIn
     animations:^{
     self.frame = self.startFrame;
     }
     completion:^(BOOL finished) {
     if (finished) {
     if (delegateFlags_.dragViewDidSwapToStartFrame)
     [self.delegate dragViewDidSwapToStartFrame:self];
     
     isAnimating_ = NO;
     isAtStartFrame_ = YES;
     isAtEndFrame_ = NO;
     }
     }];*/
    
    
}

- (void)swapToEndPositionAtIndex:(NSInteger)index{
    
    if (![self.allowFramesArray count]) return;
    
    CGRect endFrame = [[self.allowFramesArray objectAtIndex:index] CGRectValue];
    
    
    if (!isAtEndFrame_) {
        if (!canUseSameEndFrameManyTimes_) {
            
            if(![[DragManager manager] dragView:self wantSwapToEndFrame:endFrame]){
                //if(delegateFlags_.dragViewDidLeaveGoodFrame){
                //[self.delegate dragViewDidLeaveGoodFrame:self atIndex:index];
                //}
                return;
            }
        }
    }
    
    
    isAnimating_ = YES;
    
    /*if (delegateFlags_.dragViewWillSwapToEndFrame)
     [self.delegate dragViewWillSwapToEndFrame:self atIndex:index];*/
    
    self.frame = endFrame;
    
    SEL dragViewDidEndDragging = @selector(dragViewDidEndDragging:);
    
    if(self.delegate && [(NSObject *)self.delegate respondsToSelector:dragViewDidEndDragging]){
        [self.delegate dragViewDidEndDragging:self];
    }
    
    /*[UIView animateWithDuration:[self swapToEndAnimationDurationWithFrame:endFrame]
     delay:0.0f
     options:UIViewAnimationOptionCurveEaseIn
     animations:^{
     self.frame = endFrame;
     }
     completion:^(BOOL finished) {
     if (finished) {
     if (delegateFlags_.dragViewDidSwapToEndFrame)
     [self.delegate dragViewDidSwapToEndFrame:self atIndex:index];
     
     isAnimating_ = NO;
     isAtEndFrame_ = YES;
     isAtStartFrame_ = NO;
     
     }
     }];*/
}

@end




#pragma mark - DragManager

@interface DragManager ()

@property (nonatomic, strong) NSMutableArray *managerArray;

@property (nonatomic, unsafe_unretained) DTDragView *currentDragView;

@end


@implementation DragManager

@synthesize currentDragView = currentDragView_;

@synthesize managerArray = managerArray_;

static DragManager *manager; // it's a singleton, but how to relase it under ARC?

+ (DragManager *)manager{
    if (!manager) {
        manager = [[DragManager alloc] init];
    }
    
    return manager;
}

- (id)init{
    self = [super init];
    
    if(!self) return nil;
    
    self.managerArray = [NSMutableArray arrayWithCapacity:0];
    self.currentDragView = nil;
    
    
    return self;
}

- (void)addDragView:(DTDragView *)dragView{
    
    NSMutableArray *framesToAdd = [NSMutableArray arrayWithCapacity:0];
    
    
    
    if ([self.managerArray count]) {
        
        for (NSValue *dragViewValue in dragView.allowFramesArray) {
            CGRect dragViewRect = CGRectFromValue(dragViewValue);
            BOOL isInTheArray = NO;
            
            for (OccupancyIndicator *ind in self.managerArray) {
                
                CGRect managerRect = ind.frame;
                
                if (CGRectEqualToRect(managerRect, dragViewRect)) {
                    ind.count++;
                    isInTheArray = YES;
                    break;
                }
            }
            
            if (!isInTheArray) {
                [framesToAdd addObject:dragViewValue];
            }
            
        }
        
    }
    else {
        [framesToAdd addObjectsFromArray:dragView.allowFramesArray];
    }
    
    
    for (int i = 0;i < [framesToAdd count]; i++) {
        
        CGRect frame = CGRectFromValue([framesToAdd objectAtIndex:i]);
        
        OccupancyIndicator *ind = [OccupancyIndicator indicatorWithFrame:frame];
        
        [self.managerArray addObject:ind];
    }
    
    
}

- (void)removeDragView:(DTDragView *)dragView{
    NSMutableArray *arrayToRemove = [NSMutableArray arrayWithCapacity:0];
    
    for (OccupancyIndicator *ind in self.managerArray) {
        
        CGRect rect = ind.frame;
        
        for (NSValue *value in dragView.allowFramesArray) {
            
            CGRect endFrame = CGRectFromValue(value);
            
            if (CGRectEqualToRect(rect, endFrame)) {
                ind.count--;
                
                if (ind.count == 0) {
                    [arrayToRemove addObject:ind];
                }
            }
            
        }
        
    }
    
    [self.managerArray removeObjectsInArray:arrayToRemove];
    
}

- (BOOL)dragView:(DTDragView *)dragView wantSwapToEndFrame:(CGRect)endFrame{
    
    
    for (OccupancyIndicator *ind in self.managerArray) {
        
        CGRect frame = ind.frame;
        
        BOOL isTaken = !ind.isFree;
        
        if (CGRectEqualToRect(endFrame, frame)) {
            if (isTaken) {
                //[dragView swapToStartPosition];
                return NO;
            }
            else{
                ind.isFree = NO;
                return YES;
            }
        }
    }
    
    return YES;
}

- (void)dragView:(DTDragView *)dragView didLeaveEndFrame:(CGRect)endFrame{
    for (OccupancyIndicator *ind in self.managerArray) {
        CGRect frame = ind.frame;
        
        if (CGRectEqualToRect(frame, endFrame) && dragView.isAtEndFrame) {
            ind.isFree = YES;
        }
    }
}

- (BOOL)dragViewCanStartDragging:(DTDragView*)dragView{
    if (!self.currentDragView) {
        self.currentDragView = dragView;
        return YES;
    }
    else{
        return NO;
    }
}

- (void)dragViewDidEndDragging:(DTDragView *)dragView{
    if (self.currentDragView == dragView)
        self.currentDragView = nil;
}

@end

#pragma mark - TKOccupancyIndicator

@implementation OccupancyIndicator

@synthesize frame = frame_;
@synthesize count = count_;
@synthesize isFree = isFree_;

- (id)initWithFrame:(CGRect)frame{
    self = [super init];
    if(!self) return nil;
    
    self.frame = frame;
    self.isFree = YES;
    self.count = 1;
    
    return self;
    
}

+ (OccupancyIndicator *)indicatorWithFrame:(CGRect)frame{
    return [[OccupancyIndicator alloc] initWithFrame:frame];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"OccupancyIndicator: frame: %@, count: %d, isFree: %@",
            NSStringFromCGRect(self.frame), self.count, self.isFree ? @"YES" : @"NO"];
}

@end
