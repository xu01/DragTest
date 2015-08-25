//
//  DTLeftTableViewCell.m
//  DragTest
//
//  Created by xu lingyi on 8/23/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import "DTLeftTableViewCell.h"

@implementation DTLeftTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withViewController:(id)vc {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        WS(ws);
        _name = [[UILabel alloc] init];
        _name.textAlignment = NSTextAlignmentCenter;
        _name.font = [UIFont systemFontOfSize:18.0];
        [self addSubview:_name];
        [_name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(ws);
            make.centerY.equalTo(ws);
            make.size.mas_equalTo(CGSizeMake(ws.frame.size.width*0.6, 20.0));
        }];
        _img = [[UIImageView alloc] init];
        _img.contentMode =  UIViewContentModeCenter;
        _img.userInteractionEnabled = YES;
        //UILongPressGestureRecognizer *imgPan = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imagePan:)];
        //imgPan.delegate = self;
        //[_img addGestureRecognizer:imgPan];
        [self addSubview:_img];
        [_img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_name.mas_right);
            make.centerY.equalTo(ws);
            make.size.mas_equalTo(CGSizeMake(ws.frame.size.width*0.4, ws.frame.size.height));
        }];
        _dragDelegate = vc;
    }
    return self;
}

- (void)addDragView {
    /*CGPoint pt = CGPointMake(self.frame.size.width*0.6+(self.frame.size.width*0.4-_img.image.size.width)/2, (self.frame.size.height-_img.image.size.height)/2+100-10);
    NSLog(@"x:%f-y:%f", _img.mas_top.view.bounds.origin.x, _img.mas_top.view.bounds.origin.y+100);
    
    SEL buildDrageView = @selector(buildDrageViewByImage:byCenter:);
    if(self.delegate && [(NSObject *)self.delegate respondsToSelector:buildDrageView]){
        [self.delegate buildDrageViewByImage:_img.image byCenter:pt];
    }*/
    CGRect startFrame = CGRectMake(self.frame.size.width*0.6+(self.frame.size.width*0.4-_img.image.size.width)/2, (self.frame.size.height-_img.image.size.height)/2+28, _img.image.size.width, _img.image.size.height);
    
    DTBigDragView *bigDragView = [[DTBigDragView alloc] initWithImage:_img.image
                                                        withSuperView:_dragSuperView
                                                           startFrame:startFrame
                                                          allowFrames:_dragAllowFrames
                                                          andDelegate:_dragDelegate];
    [self addSubview:bigDragView];
    /*SEL buildDrageView = @selector(buildDrageView:);
    if(self.delegate && [(NSObject *)self.delegate respondsToSelector:buildDrageView]){
        [self.delegate buildDrageView:bigDragView];
    }*/
}

- (void)imagePan:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint pt = [gestureRecognizer locationInView:self.superview];
    
}

@end
