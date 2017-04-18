//
//  HomePageViewController.m
//  HelloMyBLE
//
//  Created by wilson on 2017/4/14.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "HomePageViewController.h"
#import "CentralModeTableViewController.h"
#import "GNTCommad.h"
#import "Header.h"

@interface HomePageViewController ()<CBPeripheralDelegate,CBCentralManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIButton *bindButton;
@property (weak, nonatomic) IBOutlet UIButton *cashDrawerButton;

@end

@implementation HomePageViewController
{
    CBCentralManager* manager;
    
    CBPeripheral* peripheralBM100;
    CBCharacteristic* characteristicBM100;
    
    NSMutableData* recieveBuffer;
    BOOL isHeaderExist;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"我出現了");
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(bindPasswordAlert)];
    longPress.minimumPressDuration = 2;
    [self.bindButton addGestureRecognizer:longPress];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ROOTVIEWCONTROLLER];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.statusView.layer setMasksToBounds:YES];
    [self.statusView.layer setCornerRadius:20.0f];
    self.statusView.backgroundColor = [UIColor redColor];
    
    manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    isHeaderExist = false;
    //Handle clean-up after return from TalkingViewController.
    if (peripheralBM100 != nil) {
        [manager cancelPeripheralConnection:peripheralBM100];
        peripheralBM100 = nil;
        characteristicBM100 = nil;
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (peripheralBM100 != nil) {
        [peripheralBM100 setNotifyValue:NO forCharacteristic:characteristicBM100];
        [manager cancelPeripheralConnection:peripheralBM100];
    }
    
}

-(void) showAlertWithMessage:(NSString*) message{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
    
}
#pragma mark - CBCentralManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    CBManagerState state = central.state;
    if (state != CBManagerStatePoweredOn) {
        NSString* message = [NSString stringWithFormat:@"BLE is not ready(error%ld)",(long)state];
        [self showAlertWithMessage:message];
    }else{
        if ([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_ISCONNECT]) {
            NSUUID* uuidBM100 = [[NSUUID UUID]initWithUUIDString:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY]];
            NSArray* peripheralArray = [manager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:uuidBM100]];
            if (peripheralArray.count>0) {
                peripheralBM100 = [peripheralArray objectAtIndex:0];
                NSLog(@"%@",peripheralBM100);
                [manager connectPeripheral:peripheralBM100 options:nil];
            }else{
                NSLog(@"Fail");
            }
        }
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"Peripheral connected: %@",peripheral.name);
    
    [self.statusView.layer setMasksToBounds:YES];
    [self.statusView.layer setCornerRadius:20.0f];
    self.statusView.backgroundColor = [UIColor greenColor];
    
    //Start to discover services
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:UUID_COMMUNICATE_SERVICE]]];
}
#pragma mark - CBPeripheralDelegate Methods
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    if (error) {
        NSLog(@"didDiscoverServices fail: %@",error);
        [manager cancelPeripheralConnection:peripheral];
        return;
    }
    
    for (CBService* service in peripheral.services) {
        //NSLog(@"service.UUID = ------ = %@",service.UUID.UUIDString);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:UUID_COMMUNICATE_SERVICE]]) {
            [service.peripheral discoverCharacteristics:nil forService:service];
            NSLog(@"開始尋找");
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"didDiscoverServices fail: %@",error);
        [manager cancelPeripheralConnection:peripheral];
        return;
    }
    
    //Prepare for characteristics part
    for (CBCharacteristic* tmp in service.characteristics) {
        NSLog(@"%@",tmp.UUID);
        //Check if it is the one that is matched With target UUID
        if ([tmp.UUID isEqual:[CBUUID UUIDWithString:UUID_COMMUNICATE_RECIEVE_CHARACTERISTIC]]) {
            peripheralBM100 = peripheral;
            [peripheralBM100 setNotifyValue:true forCharacteristic:tmp];
        }else if([tmp.UUID isEqual:[CBUUID UUIDWithString:UUID_COMMUNICATE_SEND_CHARACTERISTIC]]){
            characteristicBM100 = tmp;
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    NSData* callbackData = characteristic.value;
    NSLog(@"%@",callbackData);
    [self handleCallbackData:callbackData];
    
}
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (!error) {
        NSLog(@"Send Success");
    }else{
        NSLog(@"Send Fail");
    }
}

-(void)bindPasswordAlert{
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"注意" message:@"請輸入密碼解除綁定" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull pinPassword) {
        pinPassword.secureTextEntry = YES;
        pinPassword.placeholder = @"請輸入密碼";
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction* comfirm = [UIAlertAction actionWithTitle:@"確認" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField* passwordTextField = alert.textFields[0];
        NSString* password = passwordTextField.text;
        
        if ([password isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD]]) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PASSWORD];
            [self gotoScanVC];
        }else{
            [self showAlertWithMessage:@"密碼錯誤"];
        }
        
        
    }];
    [alert addAction:cancel];
    [alert addAction:comfirm];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)gotoScanVC {
    
    CentralModeTableViewController* scanVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CentralModeTableViewController"];
    
    if (peripheralBM100!=nil) {
        [manager cancelPeripheralConnection:peripheralBM100];
    }
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:DEVICE_UUID_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:false forKey:DEVICE_ISCONNECT];
    
    [self presentViewController:scanVC animated:YES completion:nil];
    
}
- (IBAction)openCashDrawer:(id)sender {
    [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Open"] forState:UIControlStateNormal];
    
    GNTCommad* command = [GNTCommad new];
    
    [peripheralBM100 writeValue:[command sendCommed:DEVICE_GET_NAME] forCharacteristic:characteristicBM100 type:CBCharacteristicWriteWithResponse];
}

#pragma mark - SendCommad Metods
-(void)handleCallbackData:(NSData*) data{
    NSUInteger len = [data length];
    const unsigned char* pcBuffer = [data bytes];
    for (int i = 0 ; i<len; i++) {
        char data = pcBuffer[i];
        if (data == (char)DEVICE_COMMAND_HEAD) {
            recieveBuffer = [NSMutableData new];
            isHeaderExist = true;
        }else if(data == (char)DEVICE_COMMAND_END){
            if (recieveBuffer.length > 0) {
                [self recieveUpdateValueFromCharacteristic];
            }
            recieveBuffer = [NSMutableData new];
            isHeaderExist = false;
        }else if(isHeaderExist){
            [recieveBuffer appendBytes:&data length:1];
        }
    }
}


//-(NSData*)creatCommandData:(char)commend Parameter:(char*)parameter{
//    
//    NSMutableData* data = [[NSMutableData alloc]init];
//    
//    const char header = (char)DEVICE_COMMAND_HEAD;
//    NSLog(@"%c",header);
//    [data appendBytes:&header length:1];
//    
//    [data appendBytes:&commend length:1];
//    NSLog(@"%c",commend);
//    if (parameter != nil) {
//        [data appendBytes:&parameter length:1];
//    }
//    
//    const char endValue = (char)DEVICE_COMMAND_END;
//    [data appendBytes:&endValue length:1];
//    
//    return data;
//}
//
//-(NSData*)sendCommed:(char)commend Parameter:(char*)parameter{
//    
//    return [self creatCommandData:commend  Parameter:parameter];
//}
//
//-(NSData*)sendCommed:(char)commend
//{
//    return [self sendCommed:commend Parameter:nil];
//}

-(void)recieveUpdateValueFromCharacteristic{
    
    NSLog(@"%@",recieveBuffer);
    
    NSString* displayLabel = [[NSString alloc]initWithData:recieveBuffer encoding:NSUTF8StringEncoding];
    
    self.deviceNameLabel.text = displayLabel;
    
    [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Close"] forState:UIControlStateNormal];
}



@end
