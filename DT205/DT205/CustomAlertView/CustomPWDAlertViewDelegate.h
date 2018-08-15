//
//  CustomPWDAlertViewDelegate.h
//  DT205
//
//  Created by Gianni on 2018/8/15.
//  Copyright © 2018年 WilsonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CustomPWDAlertViewDelegate <NSObject>

@optional
-(void)okButtonTapped:(NSString*)selectedOption :(NSString*)textPIN :(NSString*)textConfirmPIN :(NSString*)textContinuationCode;
-(void)cancelButtonTapped;
@end
