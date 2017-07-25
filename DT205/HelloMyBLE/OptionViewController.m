//
//  OptionViewController.m
//  HelloMyBLE
//
//  Created by wilson on 2017/6/27.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "OptionViewController.h"
#import "CentralModeTableViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "WifiSettingTableViewController.h"
#import "TcpSocket.h"
@interface OptionViewController ()

@end

@implementation OptionViewController
{
    CentralModeTableViewController* centralModeTVC;
    WifiSettingTableViewController* wifiSettingTVC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    centralModeTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CentralMode"];
    wifiSettingTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WifiSetting"];
   // [[NSUserDefaults standardUserDefaults]setBool:nil forKey:@"Use_Wifi"];
}
- (IBAction)chooseWiFi_BTN:(id)sender {
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"Wifi_SSID"] != nil && [[NSUserDefaults standardUserDefaults]objectForKey:@"Wifi_Password"] != nil) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Use_Wifi"];
        
        TcpSocket* tcpSocket = [[TcpSocket alloc]init];
        NSString* command = [NSString stringWithFormat:@"\x02Q0,%@,%@\x0D",[[NSUserDefaults standardUserDefaults]objectForKey:@"Wifi_SSID"],[[NSUserDefaults standardUserDefaults]objectForKey:@"Wifi_Password"]];
        
        
        
        NSData* commandData = [command dataUsingEncoding:NSUTF8StringEncoding];
        [tcpSocket connectToHost:@"192.169.4.1" Port:@"1002"];
        [tcpSocket writeData:commandData];
        
        [self showViewController:centralModeTVC sender:self];
    }else{
        //[self presentViewController:wifiSettingTVC animated:YES completion:nil];
        [self showViewController:wifiSettingTVC sender:self];
    }
}
- (IBAction)chooseBLE_BTN:(id)sender {
    
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"Use_Wifi"];
    [self showViewController:centralModeTVC sender:self];
    //[self presentViewController:centralModeTVC animated:YES completion:nil];
}

@end
