//
//  HomePageViewController.h
//  
//
//  Created by wilson on 2017/4/14.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface HomePageViewController : UIViewController
@property (nonatomic,strong) NSString* device_IP;
@property (nonatomic,strong) NSString* device_Port;
@property (nonatomic,strong) NSMutableData* callBackDataBuffer;



@end
