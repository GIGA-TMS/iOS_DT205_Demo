//
//  WifiSettingTableViewController.m
//  
//
//  Created by wilson on 2017/6/30.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "WifiSettingTableViewController.h"

@interface WifiSettingTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *wifi_SSIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *wifi_PasswordTextField;

@end

@implementation WifiSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"Wifi_SSID"] != nil && [[NSUserDefaults standardUserDefaults]objectForKey:@"Wifi_Password"] != nil) {
        _wifi_SSIDTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"Wifi_SSID"];
        _wifi_PasswordTextField.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"Wifi_Password"];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (IBAction)saveDone_BTN:(id)sender {
    
    if (_wifi_SSIDTextField.text.length != 0 && _wifi_PasswordTextField.text.length != 0) {
        [[NSUserDefaults standardUserDefaults]setObject:_wifi_SSIDTextField.text forKey:@"Wifi_SSID"];
        [[NSUserDefaults standardUserDefaults]setObject:_wifi_PasswordTextField.text forKey:@"Wifi_Password"];
        
     [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (IBAction)cancel_BTN:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
