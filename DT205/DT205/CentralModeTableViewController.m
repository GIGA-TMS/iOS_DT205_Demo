//
//  CentralModeTableViewController.m
//  
//
//  Created by 陳維成 on 2017/2/9.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "CentralModeTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralItem.h"
#import "HomePageViewController.h"
#import "Header.h"
#import "BLE_Helper.h"
#import "UdpSocket.h"
#import "DeviceItem.h"
@interface CentralModeTableViewController ()
{
    //BLE
    BLE_Helper* ble_helper;
    
    NSMutableDictionary* allItems;
    NSDate* lastTableViewReloadDate;
    NSIndexPath* indexPath1;
    
    BOOL use_Wifi;
    UdpSocket* udpSocket;
}
@end

@implementation CentralModeTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    use_Wifi = [[NSUserDefaults standardUserDefaults]boolForKey:@"Use_Wifi"];
    allItems = [NSMutableDictionary new];
    indexPath1 = [NSIndexPath new];
    
    if (use_Wifi) {
        udpSocket = [[UdpSocket alloc]init];
    }else{
        ble_helper = [BLE_Helper sharedInstance];
    }
    
    
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh) name:@"DiscorverPeripheral" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh) name:@"DiscoverDevice" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DiscorverPeripheral" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DiscoverDevice" object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return allItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSArray* allKeys = allItems.allKeys;
    NSString* uuidKey = allKeys[indexPath.row];
    NSString* line1String = [NSString new];
    NSString* line2String = [NSString new];
    if (use_Wifi) {
        DeviceItem* item = allItems[uuidKey];
        line1String = [NSString stringWithFormat:@"%@",item.deviecName];
        line2String = [NSString stringWithFormat:@"Last seen: %.2f seconds ago.",[[NSDate date] timeIntervalSinceDate:item.seenDate]];
    }else{
        PeripheralItem* item = allItems[uuidKey];
        line1String = [NSString stringWithFormat:@"%@ RSSI: %ld",item.localName,(long)item.rssi];
        line2String = [NSString stringWithFormat:@"Last seen: %.2f seconds ago.",[[NSDate date] timeIntervalSinceDate:item.seenDate]];
    }
    
    cell.textLabel.text = line1String;
    cell.detailTextLabel.text = line2String;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    indexPath1 = indexPath;
    [self settingPasswordAlert];
  
}
-(void)refresh{
    
    if (use_Wifi) {
        allItems = udpSocket.allDeviceItems;
    }else{
        allItems = ble_helper.allPeripheralItems;
    }
    [self.tableView reloadData];
}
#pragma mark - Methods
- (IBAction)enableScanValueChanged:(id)sender {
    if ([sender isOn]) {
        if (use_Wifi) {
            NSString* command = @"Y";
            NSData* commandData = [command dataUsingEncoding:NSUTF8StringEncoding];
            [udpSocket sendData:commandData toHost:@"255.255.255.255" port:65535 withTimeout:-1 tag:1];
        }else{
            [ble_helper startToScan];
        }
        
    }else{
        
        if (!use_Wifi) {
            [ble_helper stopScanning];
        }
        allItems = [NSMutableDictionary new];
        [self.tableView reloadData];
    }
}
-(void) showAlertWithMessage:(NSString*) message{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
}
-(void)settingPasswordAlert{
    
    NSArray* allKeys = allItems.allKeys;
    NSString* uuidKey = allKeys[indexPath1.row];
    if (use_Wifi) {
        DeviceItem* item = allItems[uuidKey];
        HomePageViewController* pageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageViewController"];
        [[NSUserDefaults standardUserDefaults] setObject:item.deviecName forKey:@"SelectedDeviceName"];
        pageVC.device_IP = item.deviecIP;
        pageVC.device_Port = item.deviecPort;
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:DEVICE_ISCONNECT];
    }else{
        PeripheralItem* item = allItems[uuidKey];
        [ble_helper connectPeripheral:item.peripheral];
    }
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Please enter bonding PIN code" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull pinPassword) {
        pinPassword.secureTextEntry = YES;
        pinPassword.placeholder = @"Please enter bonding PIN code";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull checkPinPassword) {
        checkPinPassword.secureTextEntry = YES;
        checkPinPassword.placeholder = @"Enter bonding PIN code again";
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction* comfirm = [UIAlertAction actionWithTitle:@"Comfirm" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField* passwordTextField = alert.textFields[0];
        UITextField* checkPasswordTextField = alert.textFields[1];
        NSString* password = passwordTextField.text;
        NSString* checkPassword = checkPasswordTextField.text;
        
        if ([password isEqualToString:checkPassword]) {
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:PASSWORD];
            if ([[NSUserDefaults standardUserDefaults]boolForKey:DEVICE_ISCONNECT]) {
                if (![[NSUserDefaults standardUserDefaults]boolForKey:ROOTVIEWCONTROLLER]) {
                    HomePageViewController* pageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageViewController"];
                   [self presentViewController:pageVC animated:YES completion:nil];
                }else{
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        }else{
            [self showAlertWithMessage:@"Incorrect bonding PIN code"];
            if (!use_Wifi) {
                [ble_helper cancelPeripheral];
            }
           
        }
    }];
    [alert addAction:cancel];
    [alert addAction:comfirm];
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end
