//
//  DHDrawerViewController.h
//  Orthopaedics
//
//  Created by DreamHack on 15-9-15.
//  Copyright (c) 2015年 DreamHack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHDrawerViewController : UIViewController

@property (nonatomic, strong, readonly) UIViewController * mainViewController;
@property (nonatomic, strong, readonly) UIViewController * leftViewController;
@property (nonatomic, strong, readonly) UIViewController * rightViewController;

/**
 打开左抽屉的右滑手势，在.h里面留出来，给外面解决手势冲突
 */
@property (nonatomic, strong, readonly) UIScreenEdgePanGestureRecognizer * drawerOpenningGesture;

// designate
- (instancetype)initWithMainViewController:(UIViewController *)mainViewController leftViewController:(UIViewController *)leftViewController rightViewController:(UIViewController *)rightViewController;

// secondary
- (instancetype)initWithMainViewController:(UIViewController *)mainViewController leftViewController:(UIViewController *)leftViewController;

// 抽屉的打开和关闭
- (void)openLeftViewController;
- (void)closeLeftViewController;

@end
