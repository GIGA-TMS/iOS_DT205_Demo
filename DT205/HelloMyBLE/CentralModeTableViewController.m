//
//  CentralModeTableViewController.m
//  HelloMyBLE
//
//  Created by 陳維成 on 2017/2/9.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "CentralModeTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralItem.h"
#import "HomePageViewController.h"
#import "Header.h"

@interface CentralModeTableViewController ()<CBCentralManagerDelegate>
{
    CBCentralManager* manager;
    
    NSMutableDictionary* allItems;
    NSDate* lastTableViewReloadDate;
    
    CBPeripheral* peripheralBM100;
    NSIndexPath* indexPath1;
}
@end

@implementation CentralModeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"我出現了. . .. . . . .");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // queue設定nil 會在main queue
    manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    allItems = [NSMutableDictionary new];
    indexPath1 = [NSIndexPath new];
    //isHeaderExist = false;
    
//    const char cTestPackage1s[]="\0020123456789ABCDEF1234";
//    const char cTestPackage2s[]="0123456789ABCDEF12345";
//    const char cTestPackage3s[]="0123456789ABCDEF1234\r";
//    NSData* dataTest = [NSData dataWithBytes:cTestPackage1s length:sizeof(cTestPackage1s)-1];
//    [self handleCallbackData:dataTest];
//    dataTest = [NSData dataWithBytes:cTestPackage2s length:sizeof(cTestPackage2s)-1];
//    [self handleCallbackData:dataTest];
//    dataTest = [NSData dataWithBytes:cTestPackage3s length:sizeof(cTestPackage3s)-1];
//    [self handleCallbackData:dataTest];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    if (peripheralBM100 != nil) {
        [manager cancelPeripheralConnection:peripheralBM100];
        peripheralBM100 = nil;
    }
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (peripheralBM100 != nil) {
        [manager cancelPeripheralConnection:peripheralBM100];
        peripheralBM100 = nil;
    }
    
}
-(void)dealloc{
    NSLog(@"我消失了222");
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
    PeripheralItem* item = allItems[uuidKey];
    
    NSString* line1String = [NSString stringWithFormat:@"%@ RSSI: %ld",item.peripheral.name,(long)item.rssi];
    NSString* line2String = [NSString stringWithFormat:@"Last seen: %.2f seconds ago.",[[NSDate date] timeIntervalSinceDate:item.seenDate]];
    
    cell.textLabel.text = line1String;
    cell.detailTextLabel.text = line2String;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    indexPath1 = indexPath;
    [self settingPasswordAlert];
}


//-(void)connectWithIndexPath:(NSIndexPath*)indexPath{
//    [self settingPasswordAlert];
//    
////    NSArray* allKeys = allItems.allKeys;
////    NSString* uuidKey = allKeys[indexPath.row];
////    PeripheralItem* item = allItems[uuidKey];
////    
////    [manager connectPeripheral:item.peripheral options:nil];
//    
//}


#pragma mark - Methods


- (IBAction)enableScanValueChanged:(id)sender {
    if ([sender isOn]) {
        [self startToScan];
    }else{
        [self stopScanning];
    }
}

-(void) startToScan{
    // 指定掃描特定service
    [self.tableView reloadData];
    CBUUID* uuid = [CBUUID UUIDWithString:TARGET_UUID_PREFIX];
    NSArray* services = @[uuid]; //@[uuid];
    //是否允許重複
    NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(true)};
    //帶空陣列 或 nil 可以做無差別掃描
    [manager scanForPeripheralsWithServices:services options:options];
}
-(void) stopScanning{
    [manager stopScan];
}
-(void) showAlertWithMessage:(NSString*) message{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
}
-(void)settingPasswordAlert{
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"注意" message:@"請輸入密碼以綁定" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull pinPassword) {
        pinPassword.secureTextEntry = YES;
        pinPassword.placeholder = @"請輸入密碼";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull checkPinPassword) {
        checkPinPassword.secureTextEntry = YES;
        checkPinPassword.placeholder = @"再次輸入密碼";
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction* comfirm = [UIAlertAction actionWithTitle:@"確認" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField* passwordTextField = alert.textFields[0];
        UITextField* checkPasswordTextField = alert.textFields[1];
        NSString* password = passwordTextField.text;
        NSString* checkPassword = checkPasswordTextField.text;
        
        if ([password isEqualToString:checkPassword]) {
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:PASSWORD];
            
            NSArray* allKeys = allItems.allKeys;
            NSString* uuidKey = allKeys[indexPath1.row];
            PeripheralItem* item = allItems[uuidKey];
            [manager connectPeripheral:item.peripheral options:nil];
            
        }else{
            [self showAlertWithMessage:@"密碼不一致"];
        }
    }];
    
    [alert addAction:cancel];
    [alert addAction:comfirm];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
#pragma mark - CBCentralManagerDelegate Methods
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    CBManagerState state = central.state;
    if (state != CBManagerStatePoweredOn) {
        NSString* message = [NSString stringWithFormat:@"BLE is not ready(error%ld)",(long)state];
        [self showAlertWithMessage:message];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    PeripheralItem* existItem = allItems[peripheral.identifier.UUIDString];
    
    if (existItem == nil) {
        NSLog(@"Discorver %@,RSSI: %ld,UUID: %@\n,AdvData: %@",peripheral.name,(long)RSSI.integerValue,peripheral.identifier.UUIDString,advertisementData.description);
    }
    
    PeripheralItem* newItem = [PeripheralItem new];
    newItem.peripheral = peripheral;
    newItem.rssi = RSSI.integerValue;
    newItem.seenDate = [NSDate date];
    [allItems setObject:newItem forKey:peripheral.identifier.UUIDString];
    
    // check if we should reload tableView or not.
    NSDate* now = [NSDate date];
    // 可以控制多久更新tableView
    if (existItem == nil || [now timeIntervalSinceDate:lastTableViewReloadDate] > RELOAD_TIME_INTERVAL) {
        lastTableViewReloadDate = now;
        [self.tableView reloadData];
    }
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //連上設備後 先把掃描停止
    
    NSLog(@"Peripheral connected: %@",peripheral.name);
    [[NSUserDefaults standardUserDefaults] setObject: peripheral.identifier.UUIDString forKey:DEVICE_UUID_KEY];
    [[NSUserDefaults standardUserDefaults] setBool: true forKey:DEVICE_ISCONNECT];
    
    peripheralBM100 = peripheral;
    [self stopScanning];
    
    [manager cancelPeripheralConnection:peripheral];
    
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:ROOTVIEWCONTROLLER]) {
        HomePageViewController* pageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageViewController"];
        [self presentViewController:pageVC animated:YES completion:nil];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSString* message = [NSString stringWithFormat:@"Fail to connect: %@",error];
    [self showAlertWithMessage:message];
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
}



@end
