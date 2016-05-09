//
//  MainViewController.m
//  DHDrawerViewController
//
//  Created by DreamHack on 16/5/9.
//  Copyright © 2016年 DreamHack. All rights reserved.
//

#import "MainViewController.h"
#import "DHDrawerViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(15, 15, 80, 40);
    [button setTitle:@"open" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openDrawer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)openDrawer:(id)sender {
    DHDrawerViewController * drawerVC = (DHDrawerViewController *)self.parentViewController;
    
    [drawerVC openLeftViewController];
}


@end
