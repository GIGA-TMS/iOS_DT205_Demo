//
//  DeviceItemTableViewCell.h
//  DT205
//
//  Created by Gianni on 2018/7/17.
//  Copyright © 2018年 WilsonChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labDevName;
@property (weak, nonatomic) IBOutlet UILabel *labDevMacAddr;
@property (weak, nonatomic) IBOutlet UILabel *labDevRSSI;
@end
