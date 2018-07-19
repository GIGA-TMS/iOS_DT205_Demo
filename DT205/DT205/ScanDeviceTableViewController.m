//
//  ScanDeviceTableViewController.m
//  DT205
//
//  Created by Gianni on 2018/7/18.
//  Copyright © 2018年 WilsonChen. All rights reserved.
//

#import "ScanDeviceTableViewController.h"
#import <DT205SDK/DT205.h>
#import <DT205SDK/Header.h>
#import "DeviceItemTableViewCell.h"
#import <DT205SDK/EthernetDevice.h>
#import <DT205SDK/PeripheralItem.h>
#import "HomePageViewController.h"

@interface ScanDeviceTableViewController ()

@end

@implementation ScanDeviceTableViewController
{
    NSMutableDictionary* allItems;
    DT205 *dt205;
    BOOL use_Wifi;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    allItems = [NSMutableDictionary new];
    use_Wifi = false;
    dt205 = [DT205 sharedInstance:use_Wifi];
    [self getAppVersion];
}

- (void)getAppVersion {
    //To get the version number
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * versionBuildString = [NSString stringWithFormat:@"APP v%@.%@, SDK v%@", appVersionString, appBuildString, [dt205 getSDKVersion]];
    NSLog(@"Gianni appVersionString: %@ , appBuildString: %@",appVersionString,appBuildString);
    [_labAppVer setText:versionBuildString];
    [_labAppVer setBackgroundColor:[UIColor clearColor]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (use_Wifi) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh) name:@"DiscorverEtherDev" object:nil];
    }else{
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh) name:@"DiscorverPeripheral" object:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DiscorverPeripheral" object:nil];
}

- (IBAction)scanDevice:(id)sender {
    
    if ([sender isOn]) {
        if (use_Wifi) {
            [dt205 startToScanEthernetDevice];
        }else{
            [dt205 startToScanBLEDevice];
        }
    }else{
        if (use_Wifi) {
            
        }else{
            [dt205 stopScanningBLEDevice];
        }
        [allItems removeAllObjects];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(refresh)
                                   userInfo:nil
                                    repeats:NO];
}

- (IBAction)isUseWifi:(id)sender {
    use_Wifi = [sender isOn];
    dt205 = [dt205 init];
    [allItems removeAllObjects];
    [self refresh];
}

-(void)refresh{
    if (use_Wifi) {
        allItems = [dt205 getAllEthernetDevice];
        NSLog(@"getAllEthernetDevice %lu",(unsigned long)[allItems count]);
    }else{
        allItems = [dt205 getAllBLEDevice];
        NSLog(@"getAllBLEDevice %lu",(unsigned long)[allItems count]);
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return allItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScanCell" forIndexPath:indexPath];
    
    NSArray* allKeys = allItems.allKeys;
    NSString* uuidKey = allKeys[indexPath.row];
    
    NSString* line1String = [NSString new];
    NSString* line2String = [NSString new];
    NSString* line3String = [NSString new];
    if (use_Wifi) {
        EthernetDevice* item = allItems[uuidKey];
        line1String = [NSString stringWithFormat:@"%@",item.deviecName];
        line2String = [NSString stringWithFormat:@"%@",item.deviecMacAddr];
    }else{
        PeripheralItem* item = allItems[uuidKey];
        line1String = [NSString stringWithFormat:@"%@",item.localName];
        line2String = [NSString stringWithFormat:@"%@",uuidKey];
        line3String = [NSString stringWithFormat:@"   RSSI: %ld",(long)item.rssi];
    }
    cell.labDevName.text = line1String;
    cell.labDevMacAddr.text = line2String;
    cell.labDevRSSI.text = line3String;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (use_Wifi) {
//        NSArray* allKeys = allItems.allKeys;
//        NSString* macAddrKey = allKeys[indexPath.row];
//        EthernetDevice* item = allItems[macAddrKey];
//        [dt205 connectEthernetDevice:item.deviecIP Port:item.deviecPort];
//    }else{
//        NSArray* allKeys = allItems.allKeys;
//        NSString* uuidKey = allKeys[indexPath.row];
//        PeripheralItem* item = allItems[uuidKey];
//        [dt205 connectBLEDevice:item.peripheral];
//    }
    [self settingPasswordAlert:indexPath];
}

-(void) showAlertWithMessage:(NSString*) message{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
}

-(void)settingPasswordAlert:(NSIndexPath *)indexPath{
    NSArray* allKeys = allItems.allKeys;
    NSString* uuidKey = allKeys[indexPath.row];
    if (use_Wifi) {
        EthernetDevice* item = allItems[uuidKey];
        HomePageViewController* pageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageViewController"];
        [[NSUserDefaults standardUserDefaults] setObject:item.deviecName forKey:@"SelectedDeviceName"];
        pageVC.device_IP = item.deviecIP;
        pageVC.device_Port = item.deviecPort;
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:DEVICE_ISCONNECT];
    }else{
        PeripheralItem* item = allItems[uuidKey];
        [dt205 connectBLEDevice:item.peripheral];
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
                [dt205 disconnectBLEDevice];
            }
            
        }
    }];
    [alert addAction:cancel];
    [alert addAction:comfirm];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
