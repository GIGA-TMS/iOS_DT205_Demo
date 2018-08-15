//
//  CustomPWDAlertView.h
//  DT205
//
//  Created by Gianni on 2018/8/15.
//  Copyright © 2018年 WilsonChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPWDAlertViewDelegate.h"

@interface CustomPWDAlertView : UIViewController
@property (nonatomic, assign) id<CustomPWDAlertViewDelegate> pwdAlertViewDelegate;
@end
