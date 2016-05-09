//
//  DHDrawerViewController.m
//  Orthopaedics
//
//  Created by DreamHack on 15-9-15.
//  Copyright (c) 2015年 DreamHack. All rights reserved.
//

#import "DHDrawerViewController.h"

static const CGFloat duration_      =   0.4f;
static const CGFloat damping_       =   0.7f;
static const CGFloat velocity_      =   15.f;
static const CGFloat leftWidth_     =   300.f;
static const CGFloat originScale_   =   0.8f;

@interface DHDrawerViewController ()

@property (nonatomic, strong) UIViewController * mainViewController;
@property (nonatomic, strong) UIViewController * leftViewController;
@property (nonatomic, strong) UIViewController * rightViewController;

@property (nonatomic, strong) UIView * maskView;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer * drawerOpenningGesture;

- (void)initializeAppearance;
/**
 *  线性插值
 *
 *  @param from    起始值
 *  @param to      结束值
 *  @param percent 另一个变量当前变化值占总可变值的百分比
 *
 *  @return 插值结果
 */
- (CGFloat)interpolateFrom:(CGFloat)from to:(CGFloat)to percent:(CGFloat)percent;

/**
 *  在打开抽屉的时候添加mask，在关闭抽屉后移除mask。
 *  单击和拖动关闭抽屉的手势添加到maskView上面
 */
- (void)addMask;
- (void)removeMask;

@end

@implementation DHDrawerViewController


#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeAppearance];
}

#pragma mark - initialize
// designate
- (instancetype)initWithMainViewController:(UIViewController *)mainViewController leftViewController:(UIViewController *)leftViewController rightViewController:(UIViewController *)rightViewController
{
    self = [super init];
    if (self) {
        self.mainViewController = mainViewController;
        self.leftViewController = leftViewController;
        self.rightViewController = rightViewController;
    }
    return self;
}

// secondary
- (instancetype)initWithMainViewController:(UIViewController *)mainViewController leftViewController:(UIViewController *)leftViewController
{
    self = [self initWithMainViewController:mainViewController leftViewController:leftViewController rightViewController:nil];
    
    return self;
}

#pragma mark - 私有方法
- (void)initializeAppearance
{
    self.leftViewController.view.transform = CGAffineTransformMakeScale(originScale_, originScale_);
    [self addChildViewController:self.leftViewController];
    [self addChildViewController:self.mainViewController];
    [self.view addSubview:self.mainViewController.view];
    [self.view addGestureRecognizer:self.drawerOpenningGesture];
}

- (CGFloat)interpolateFrom:(CGFloat)from to:(CGFloat)to percent:(CGFloat)percent
{
    return from + (to - from) * percent;
}

- (void)addMask
{
    if (!self.maskView.superview) {
        [self.mainViewController.view addSubview:self.maskView];
    }
}

- (void)removeMask
{
    if (self.maskView.superview) {
        [self.maskView removeFromSuperview];
    }
}

#pragma mark - 重写方法
- (void)addChildViewController:(UIViewController *)childController
{
    [super addChildViewController:childController];
    [childController didMoveToParentViewController:self];
}

#pragma mark - 接口方法
- (void)openLeftViewController
{
    if (!self.leftViewController.view.superview) {
        // 如果左抽屉视图还没有加上去
        [self.view insertSubview:self.leftViewController.view belowSubview:self.mainViewController.view];
    }
    [self addMask];
    [UIView animateWithDuration:duration_ delay:0 usingSpringWithDamping:damping_ initialSpringVelocity:velocity_ options:UIViewAnimationOptionCurveLinear animations:^{
        // mainVC右移
        self.mainViewController.view.center = CGPointMake(CGRectGetWidth(self.mainViewController.view.bounds)/2 + leftWidth_, self.mainViewController.view.center.y);
        self.leftViewController.view.transform = CGAffineTransformMakeScale(1, 1);
        self.leftViewController.view.alpha = 1;
        self.maskView.alpha = 0.6;
    } completion:^(BOOL finished) {
        // 打开抽屉后，移除打开抽屉的手势
        [self.view removeGestureRecognizer:self.drawerOpenningGesture];
    }];
}

- (void)closeLeftViewController
{
    [UIView animateWithDuration:duration_ delay:0 usingSpringWithDamping:damping_ initialSpringVelocity:velocity_ options:UIViewAnimationOptionCurveLinear animations:^{
        // mainVC右移
        self.mainViewController.view.center = CGPointMake(CGRectGetWidth(self.mainViewController.view.bounds)/2, self.mainViewController.view.center.y);
        self.leftViewController.view.transform = CGAffineTransformMakeScale(originScale_, originScale_);
        self.leftViewController.view.alpha = 0;
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeMask];
        [self.leftViewController.view removeFromSuperview];
        // 关闭抽屉后，添加打开抽屉的手势
        [self.view addGestureRecognizer:self.drawerOpenningGesture];
    }];
}

#pragma mark - 回调方法（按钮点击事件、手势的响应、通知的响应、系统的回调...）
- (void)action_onGesture:(UIScreenEdgePanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {

        [self addMask];
        [self.view insertSubview:self.leftViewController.view belowSubview:self.mainViewController.view];

    } else if (sender.state == UIGestureRecognizerStateChanged) {

        // 控制抽屉vc的动画进程
        CGPoint translation = [sender translationInView:self.view];
        CGFloat percent = fabs(translation.x)/320.f;
        if (percent > 1) {
            percent = 1;
        }
        // 初始状态，把center.x作为初始状态
        CGFloat from = self.mainViewController.view.frame.size.width/2;
        // 把结束点的center.x作为结束状态，这样插值出来的结果就是当前状态的center.x
        CGFloat to = from + leftWidth_;
        CGFloat x = [self interpolateFrom:from to:to percent:percent];
        // 给视图赋值
        self.mainViewController.view.center = CGPointMake(x, self.mainViewController.view.center.y);
        // 左抽屉从originScale缩放到1倍大小
        CGFloat scale = [self interpolateFrom:originScale_ to:1 percent:percent];
        
        self.leftViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        // 对左抽屉的alpha进行插值
        CGFloat alpha = [self interpolateFrom:0 to:1 percent:percent];
        self.leftViewController.view.alpha = alpha;
        // 对maskView的alpha进行插值
        CGFloat maskAlpha = [self interpolateFrom:0 to:0.6 percent:percent];
        self.maskView.alpha = maskAlpha;
        
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
//        if (!self.shouldBeginOpenning) {
//            return;
//        }
//        
        // 如果速度向右，则打开抽屉，否则，关闭抽屉
        CGPoint velocity = [sender velocityInView:self.view];
        if (velocity.x > 0) {
            [self openLeftViewController];
        } else {
            [self closeLeftViewController];
        }
        
    }
}

- (void)action_onTapMask:(UITapGestureRecognizer *)sender
{
    [self closeLeftViewController];
}

- (void)action_onPanMask:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
       
    } else if (sender.state == UIGestureRecognizerStateChanged) {

        // 控制抽屉vc的动画进程
        CGPoint translation = [sender translationInView:self.view];
        CGFloat percent = fabs(translation.x)/leftWidth_;
        if (percent > 1) {
            percent = 1;
        }
        // 初始状态，把center.x作为初始状态
        CGFloat to = self.mainViewController.view.frame.size.width/2;
        // 把结束点的center.x作为结束状态，这样插值出来的结果就是当前状态的center.x
        CGFloat from = to + leftWidth_;
        CGFloat x = [self interpolateFrom:from to:to percent:percent];
        // 给视图赋值
        self.mainViewController.view.center = CGPointMake(x, self.mainViewController.view.center.y);
        // 左抽屉从originScale缩放到1倍大小
        CGFloat scale = [self interpolateFrom:1 to:originScale_ percent:percent];
        
        self.leftViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        // 对左抽屉的alpha进行插值
        CGFloat alpha = [self interpolateFrom:1 to:0 percent:percent];
        self.leftViewController.view.alpha = alpha;
        // 对maskView的alpha进行插值
        CGFloat maskAlpha = [self interpolateFrom:0.6 to:0 percent:percent];
        self.maskView.alpha = maskAlpha;
        
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
 
        // 如果速度向右，则打开抽屉，否则，关闭抽屉
        CGPoint velocity = [sender velocityInView:self.view];
        if (velocity.x > 0) {
            [self openLeftViewController];
        } else {
            [self closeLeftViewController];
        }
        
    }

}

#pragma mark - getter
- (UIScreenEdgePanGestureRecognizer *)drawerOpenningGesture
{
    if (!_drawerOpenningGesture) {
        _drawerOpenningGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(action_onGesture:)];
        _drawerOpenningGesture.edges = UIRectEdgeLeft;
    }
    return _drawerOpenningGesture;
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = ({
        
            UIView * view = [[UIView alloc] initWithFrame:self.mainViewController.view.bounds];
            view.alpha = 0;
            view.backgroundColor = [UIColor blackColor];
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(action_onTapMask:)]];
            [view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(action_onPanMask:)]];
            
            view.layer.shadowOpacity = 0.7;
            view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
            view;
            
        });
    }
    return _maskView;
}

@end
