//
//  DTMainViewController.m
//  DragTest
//
//  Created by xu lingyi on 8/23/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import "DTMainViewController.h"

@interface DTMainViewController ()
{
    UITableView     *_leftTableView;
    UIScrollView    *_rightScrollView;
    UIView          *_rightView;
    NSArray         *_leftData;
    
    int             _numMoving;
}

@end

@implementation DTMainViewController

- (instancetype)init {
    if (self = [super init]) {
        _leftData = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LeftTableData" ofType:@"plist"]];
        _numMoving = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"Demo";
    
    WS(ws);
    
    _leftTableView = [[UITableView alloc] init];
    _leftTableView.dataSource = self;
    _leftTableView.delegate = self;
    _leftTableView.bounces = YES;
    _leftTableView.allowsSelection = NO;
    [self.view addSubview:_leftTableView];
    [_leftTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.view);
        make.top.equalTo(ws.view).with.offset(0.0);
        make.size.mas_equalTo(CGSizeMake(ws.view.frame.size.width*0.3, ws.view.frame.size.height));
    }];
    
    _rightScrollView = [[UIScrollView alloc] init];
    _rightScrollView.scrollEnabled = YES;
    _rightScrollView.bounces = NO;
    [self.view addSubview:_rightScrollView];
    _rightScrollView.contentSize = CGSizeMake(kRows*kWidth, kColumns*kWidth+kNavigationBarHeight+kStatusBarHeight);
    [_rightScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftTableView.mas_right);
        make.top.equalTo(ws.view).with.offset(kNavigationBarHeight+kStatusBarHeight);
        make.size.mas_equalTo(CGSizeMake(ws.view.frame.size.width*0.7, ws.view.frame.size.height));
    }];
    
    _rightView = [[UIView alloc] init];
    [_rightScrollView addSubview:_rightView];
    [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_rightScrollView);
        make.size.mas_equalTo(CGSizeMake(kRows*kWidth, kColumns*kWidth+kNavigationBarHeight+kStatusBarHeight));
    }];
    
    NSMutableArray *sFrames = [NSMutableArray arrayWithCapacity:kRows*kColumns];
    NSMutableArray *bFrames = [NSMutableArray arrayWithCapacity:(kRows-1)*(kColumns-1)];
    
    for (int row=0; row<kRows; row++) {
        for (int col=0; col<kColumns; col++) {
            CGRect sFrame = CGRectMake(row*kWidth, col*kWidth, kWidth, kWidth);
            
            [sFrames addObject:CGRectValue(sFrame)];
            
            UIView *helpView = [[UIView alloc] initWithFrame:sFrame];
            helpView.layer.borderColor = [UIColor grayColor].CGColor;
            helpView.layer.borderWidth = 1.0f;
            
            [_rightView addSubview:helpView];
        }
    }
    _smallTableFrames = sFrames;
    
    for (int row=0; row<(kRows-1); row++) {
        for (int col=0; col<(kColumns-1); col++) {
            CGRect bFrame = CGRectMake(row*kWidth, col*kWidth, kWidth*2, kWidth*2);
            
            [bFrames addObject:CGRectValue(bFrame)];
        }
    }
    _bigTableFrames = bFrames;
    
    _rightScrollView.delegate = self;
    _rightScrollView.minimumZoomScale = 0.5;
    _rightScrollView.maximumZoomScale = 2.0;
    
    //[_rightScrollView setZoomScale:0.5 animated:YES];
    
}

#pragma mark - UITableViewDataSource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _leftData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"_LeftTableViewCell";
    DTLeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell){
        cell = [[DTLeftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withViewController:self];
    }
    cell.name.text = _leftData[indexPath.row][@"name"];
    cell.img.image = [UIImage imageNamed:_leftData[indexPath.row][@"image"]];
    cell.imgType = indexPath.row+1000;
    cell.delegate = self;
    cell.dragAllowFrames = _bigTableFrames;
    cell.dragSuperView = _rightScrollView;
    [cell addDragView];
    
    return cell;
}

- (void)buildDrageView:(DTBigDragView *)bigDragView {
    if (_numMoving < 1) {
        [self.view addSubview:bigDragView];
        [self.view bringSubviewToFront:bigDragView];
        _numMoving++;
    }
}

/*
- (void)buildDragViewByImage:(UIImage *)image byOrigin:(CGPoint)origin {
    UIImage *dragImage = [image mutableCopy];
    
    CGRect startFrame = CGRectMake(origin.x, origin.y, dragImage.size.width, dragImage.size.height);
    
    
    DTBigDragView *bigDragView = [[DTBigDragView alloc] initWithImage:image
                                                           startFrame:startFrame
                                                          allowFrames:_bigTableFrames
                                                          andDelegate:self];
    
    [self.view addSubview:bigDragView];
}
*/

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _rightView;
}

- (void)dragViewDidStartDragging:(DTDragView *)dragView isSmall:(BOOL)isSmall {
    //if (![dragView.superview isKindOfClass:[self.view class]]) {
        //[self.view addSubview:dragView];
    //}
}

- (void)dragViewDidEndDragging:(DTDragView *)dragView {
    if (_numMoving > 0)_numMoving--;
    [_rightView addSubview:dragView];
}

#pragma mark - Default Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
