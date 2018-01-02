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
    
    [self getVersion];
}

- (void)getVersion {
    //To get the version number
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * versionBuildString = [NSString stringWithFormat:@"Version: %@.%@", appVersionString, appBuildString];
    NSLog(@"Gianni appVersionString: %@ , appBuildString: %@",appVersionString,appBuildString);
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    //    CGRectMake(10,(screenHeight - height - 10),width,height);
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10,(screenHeight - 100 - 10),200,50)];
    
    
    [lbl setText:versionBuildString];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:lbl];
    [lbl sizeToFit];
}

- (IBAction)chooseWiFi_BTN:(id)sender {
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"Wifi_SSID"] != nil && [[NSUserDefaults standardUserDefaults]objectForKey:@"Wifi_Password"] != nil) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Use_Wifi"];
        
        TcpSocket* tcpSocket = [[TcpSocket alloc]init];
        NSString* command = [NSString stringWithFormat:@"\x02Q0,%@,%@\x0D",[[NSUserDefaults standardUserDefaults]objectForKey:@"Wifi_SSID"],[[NSUserDefaults standardUserDefaults]objectForKey:@"Wifi_Password"]];
        
        
        
        NSData* commandData = [command dataUsingEncoding:NSUTF8StringEncoding];
        [tcpSocket connectToHost:@"192.168.4.1" Port:@"1002"];
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
