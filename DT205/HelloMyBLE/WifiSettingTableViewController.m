//
//  WifiSettingTableViewController.m
//  HelloMyBLE
//
//  Created by wilson on 2017/6/30.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "WifiSettingTableViewController.h"
#import "TcpSocket.h"
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

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
