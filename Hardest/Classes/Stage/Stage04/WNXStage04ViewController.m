//
//  WNXStage04ViewController.m
//  Hardest
//
//  Created by sfbest on 16/3/31.
//  Copyright © 2016年 维尼的小熊. All rights reserved.
//

#import "WNXStage04ViewController.h"
#import "WNXStage04View.h"
#import "WNXCountTimeView.h"
#import "WNXStateView.h"

@interface WNXStage04ViewController ()

@property (nonatomic, strong) WNXStage04View *imageView;
@property (nonatomic, assign) int stepsCount;
@property (nonatomic, assign) WNXResultStateType stateType;
@property (nonatomic, strong) WNXStateView *stateView;
@property (nonatomic, assign) float allAverage;

@end

@implementation WNXStage04ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self buildStageInfo];

    [self buildStageImageView];
    
    [self buildStateView];
}

- (void)buildStageInfo {
    self.backgroundIV.image = [UIImage imageNamed:@"05_bg-iphone4"];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.leftButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    [self.rightButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    
    [self.leftButton setImage:[UIImage imageNamed:@"05_Rfoot-iphone4"] forState:UIControlStateNormal];
    self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(15, 40, 15, 40);
    self.leftButton.adjustsImageWhenDisabled = NO;
    self.leftButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.rightButton setImage:[UIImage imageNamed:@"05_Yfoot-iphone4"] forState:UIControlStateNormal];
    self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(15, 40, 15, 40);
    self.rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.rightButton.adjustsImageWhenDisabled = NO;
    [self.view bringSubviewToFront:self.guideImageView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 96, ScreenHeight, self.rightButton.frame.size.height)];
    bottomView.backgroundColor = [UIColor blackColor];
    [self.view insertSubview:bottomView belowSubview:self.leftButton];
}

- (void)buttonClick:(UIButton *)sender {
    sender.enabled = NO;
    sender.alpha = 0.5;
    if (sender.tag == 1) {
        self.rightButton.enabled = YES;
        self.rightButton.alpha = 1;
        [self.imageView runLeft];
    } else {
        self.leftButton.enabled = YES;
        self.leftButton.alpha = 1;
        [self.imageView runRight];
    }
}

- (void)buildStageImageView {
    __weak typeof(self) weakSelf = self;
    self.imageView = [[WNXStage04View alloc] initWithFrame:CGRectMake(0, ScreenHeight - 96 - 300, ScreenWidth, 300)];
    if (self.guideImageView) {
        [self.view insertSubview:self.imageView belowSubview:self.guideImageView];
    } else {
        [self.view addSubview:self.guideImageView];
    }
    self.imageView.bgIV = self.backgroundIV;
    self.imageView.stopTime = ^(int count) {
        [((WNXCountTimeView *)weakSelf.countScore) stopCalculateByTimeWithTimeBlock:^(int second, int ms) {
            [weakSelf calculateStateWithCount:count second:second msec:ms];
        }];
    };
    
    self.imageView.passStage = ^() {
        weakSelf.view.userInteractionEnabled = NO;

        [weakSelf showResultControllerWithNewScroe:weakSelf.allAverage * 1000 unit:@"MS" stage:weakSelf.stage isAddScore:YES];
    };
    
    self.imageView.showResult = ^() {
        [weakSelf showStageResult];
    };
    
    self.imageView.btnToFront = ^() {
        [weakSelf.view bringSubviewToFront:weakSelf.leftButton];
        [weakSelf.view bringSubviewToFront:weakSelf.rightButton];
        if (weakSelf.guideImageView) {
            [weakSelf.view bringSubviewToFront:weakSelf.guideImageView];
        }
    };
    
    self.imageView.stopAnimationDidFinish = ^() {
        [weakSelf.imageView start];
        [weakSelf setButtonActivate:YES];
        [((WNXCountTimeView *)weakSelf.countScore) cleanData];
        [((WNXCountTimeView *)weakSelf.countScore) startCalculateByTimeWithTimeOut:nil];
    };
    
    self.imageView.failBlock = ^() {
        [weakSelf setButtonActivate:NO];
        [weakSelf showGameFail];
    };
    
    [(WNXCountTimeView *)self.countScore setNotHasTimeOut:YES];
    [self.imageView start];
    [self setButtonActivate:NO];
}

- (void)buildStateView {
    self.stateView = [WNXStateView viewFromNib];
    self.stateView.frame = CGRectMake(0, ScreenHeight - self.stateView.frame.size.height - self.leftButton.frame.size.height - 10, self.stateView.frame.size.width, self.stateView.frame.size.height);
    [self.view addSubview:self.stateView];
}

- (void)pauseGame {
    [super pauseGame];
    
    [(WNXCountTimeView *)self.countScore pause];
}

- (void)continueGame {
    [super continueGame];
    
    [(WNXCountTimeView *)self.countScore continueGame];
}

- (void)playAgainGame {
    [super playAgainGame];
    
    [(WNXCountTimeView *)self.countScore cleanData];
    [self.imageView playAgain];
    [self setButtonActivate:NO];
}
#pragma mark - 
- (void)readyGoAnimationFinish {
    [super readyGoAnimationFinish];
    
    [self setButtonActivate:YES];
    [(WNXCountTimeView *)self.countScore startCalculateByTimeWithTimeOut:nil];
}

#pragma mark
- (void)showStageResult {
    [self.stateView showStateViewWithType:self.stateType];
    [self setButtonActivate:NO];
    self.leftButton.alpha = 1;
    self.rightButton.alpha = 1;
}

- (void)calculateStateWithCount:(int)count second:(int)second msec:(int)ms {
    float time = second + ms / 60.0;
    float average = time / count;

    if (average < 0.15) {
        self.stateType = WNXResultStateTypePerfect;
    } else if (average < 0.20) {
        self.stateType = WNXResultStateTypeGreat;
    } else {
        self.stateType = WNXResultStateTypeOK;
    }
    
    _allAverage += average;
}

@end