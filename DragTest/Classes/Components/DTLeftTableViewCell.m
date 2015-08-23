//
//  DTLeftTableViewCell.m
//  DragTest
//
//  Created by xu lingyi on 8/23/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import "DTLeftTableViewCell.h"

@implementation DTLeftTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
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
        [self addSubview:_img];
        [_img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_name.mas_right);
            make.centerY.equalTo(ws);
            make.size.mas_equalTo(CGSizeMake(ws.frame.size.width*0.4, ws.frame.size.height));
        }];
    }
    return self;
}

@end
