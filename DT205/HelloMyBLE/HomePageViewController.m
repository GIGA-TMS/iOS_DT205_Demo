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
@property (weak, nonatomic) IBOutlet UILabel *deviceVersionLabel;
@property (weak, nonatomic) IBOutlet UISlider *sliderRSSI;

@end

@implementation HomePageViewController
{
    CBCentralManager* manager;
    
    CBPeripheral* peripheralDT205;
    CBCharacteristic* characteristicDT205;
    
    NSMutableData* recieveBuffer;
    BOOL isHeaderExist;
    
    GNTCommad* command;
    NSTimer* scanTimer;
    
    int peripheralRSSI;
    float rssi;
    
  //  NSTimer* getRSSI;
    int sumReadRSSI;
    int sumTarget;
    
    BOOL isCommand;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUUID* uuid =[[UIDevice currentDevice] identifierForVendor];
    NSLog(@"%@",uuid);
    NSLog(@"我出現了");
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(bindPasswordAlert)];
    longPress.minimumPressDuration = 1.0;
    
    [self.bindButton addGestureRecognizer:longPress];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ROOTVIEWCONTROLLER];
    command = [GNTCommad new];
    sumReadRSSI = 0;
    sumTarget = 0;
    
    isCommand = false;
    
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.statusView.backgroundColor = [UIColor redColor];
    self.statusLabel.text = @"Disconnect";
    
    [[self.cashDrawerButton layer] setMasksToBounds:YES];
    [[self.cashDrawerButton layer] setBorderWidth:6.0f];
    [[self.cashDrawerButton layer] setCornerRadius:150.0f];
    [[self.cashDrawerButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    isHeaderExist = false;
    //Handle clean-up after return from TalkingViewController.
    if (peripheralDT205 != nil) {
        [manager cancelPeripheralConnection:peripheralDT205];
        peripheralDT205 = nil;
        characteristicDT205 = nil;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [scanTimer invalidate];
    scanTimer = nil;
    if (peripheralDT205 != nil) {
        [peripheralDT205 setNotifyValue:NO forCharacteristic:characteristicDT205];
        [manager cancelPeripheralConnection:peripheralDT205];
    }
}

-(void)scanPeripheral{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_ISCONNECT]) {
        NSUUID* uuidBM100 = [[NSUUID UUID]initWithUUIDString:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY]];
        NSArray* peripheralArray = [manager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:uuidBM100]];
        if (peripheralArray.count>0) {
            peripheralDT205 = [peripheralArray objectAtIndex:0];
            NSLog(@"%@",peripheralDT205);
            [manager connectPeripheral:peripheralDT205 options:nil];
        }else{
            NSLog(@"Fail");
        }
    }
}
-(void) showAlertWithMessage:(NSString*) message{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:true completion:nil];
}

- (IBAction)controllRSSI:(UISlider *)sender {
    rssi = self.sliderRSSI.value;
}


#pragma mark - CBCentralManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    CBManagerState state = central.state;
    if (state != CBManagerStatePoweredOn) {
        NSString* message = [NSString stringWithFormat:@"BLE is not ready(error%ld)",(long)state];
        [self showAlertWithMessage:message];
    }else{
        [self scanPeripheral];
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"Peripheral connected: %@",peripheral.name);
    
    [scanTimer invalidate];
    scanTimer = nil;
    //Start to discover services
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:UUID_COMMUNICATE_SERVICE]]];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    self.statusView.backgroundColor = [UIColor redColor];
    self.statusLabel.text = @"Disconnect";
    
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(scanPeripheral) userInfo:nil repeats:YES];
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
            peripheralDT205 = peripheral;
            [peripheralDT205 setNotifyValue:true forCharacteristic:tmp];
        }else if([tmp.UUID isEqual:[CBUUID UUIDWithString:UUID_COMMUNICATE_SEND_CHARACTERISTIC]]){
            characteristicDT205 = tmp;
            self.statusView.backgroundColor = [UIColor greenColor];
            self.statusLabel.text = @"Connect";
            [peripheralDT205 writeValue:[command sendCommed:DEVICE_GET_NAME] forCharacteristic:characteristicDT205 type:CBCharacteristicWriteWithResponse];
            [peripheralDT205 writeValue:[command sendCommed:DEVICE_GET_STATUS Parameter:(char*)DEVICE_OPENCASHDRAWER_PARAMETER] forCharacteristic:characteristicDT205 type:CBCharacteristicWriteWithResponse];
            [peripheralDT205 writeValue:[command sendCommed:DEVICE_GET_VERSION] forCharacteristic:characteristicDT205 type:CBCharacteristicWriteWithResponse];
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
-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    
    sumReadRSSI+=[RSSI intValue];
    sumTarget++;

    peripheralRSSI = sumReadRSSI/sumTarget;
    
    NSLog(@"%d",peripheralRSSI);
}

-(void)bindPasswordAlert{
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Please enter PIN code to exit" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull pinPassword) {
        pinPassword.secureTextEntry = YES;
        pinPassword.placeholder = @"Please entet bonding PIN code";
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction* comfirm = [UIAlertAction actionWithTitle:@"Comfirm" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField* passwordTextField = alert.textFields[0];
        NSString* password = passwordTextField.text;
        
        if ([password isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD]]) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PASSWORD];
            [self gotoScanVC];
        }else{
            [self showAlertWithMessage:@"Wrong bonding PIN code"];
        }
        
    }];
    [alert addAction:cancel];
    [alert addAction:comfirm];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)gotoScanVC {
    
    CentralModeTableViewController* scanVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CentralModeTableViewController"];
    
    if (peripheralDT205!=nil) {
        [manager cancelPeripheralConnection:peripheralDT205];
    }
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:DEVICE_UUID_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:false forKey:DEVICE_ISCONNECT];
    
    [self presentViewController:scanVC animated:YES completion:nil];
    
}
- (IBAction)openCashDrawer:(id)sender {
    
    isCommand = YES;
    [peripheralDT205 readRSSI];
    NSLog(@"value:%d",(int)(rssi*-30));
        if (characteristicDT205!=nil && ((int)(rssi*-30) < peripheralRSSI)) {
            [peripheralDT205 writeValue:[command sendCommed:DEVICE_OPENCASHDRAWER Parameter:(char*)DEVICE_OPENCASHDRAWER_PARAMETER] forCharacteristic:characteristicDT205 type:CBCharacteristicWriteWithResponse];
        }else{
            [self showAlertWithMessage: @"Distance is too far"];
        }
    sumReadRSSI = 0;
    sumTarget = 0;
    
//    [getRSSI invalidate];
//    getRSSI = nil;
    
}
//-(void)getPeripheralRSSI{
//    if (peripheralBM100!=nil) {
//        getRSSI = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(readRSSI) userInfo:nil repeats:YES];
//    }
//}
//-(void)readRSSI{
//    [peripheralBM100 readRSSI];
//}

#pragma mark - HandleData Metods
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

-(void)recieveUpdateValueFromCharacteristic{
    NSLog(@"%@",recieveBuffer);
    
    NSString* displayLabel = [[NSString alloc]initWithData:recieveBuffer encoding:NSUTF8StringEncoding];
    
    if ([displayLabel isEqualToString:@"A,00"]) {
        [self.cashDrawerButton.layer removeAllAnimations];
        [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Close"] forState:UIControlStateNormal];
        [[self.cashDrawerButton layer]setBorderColor:[UIColor greenColor].CGColor];
        isCommand = false;
        return;
    }else if ([displayLabel isEqualToString:@"A,01"]){
        [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Open"] forState:UIControlStateNormal];
        if (!isCommand) {
            [self doAlarmAnimation]; 
        }else{
            [[self.cashDrawerButton layer]setBorderColor:[UIColor greenColor].CGColor];
        }
        return;
    }else if ([displayLabel containsString:@"A,ROM"]) {
        NSString* display = [displayLabel substringFromIndex:2];
        NSString* version = [NSString stringWithFormat:@"F/W Version:%@",display];
        self.deviceVersionLabel.text = version;
        return;
    }else if ([displayLabel containsString:@"A,"]){
        NSString* name = [displayLabel substringFromIndex:2];
        self.deviceNameLabel.text = name;
        return;
    }
}
-(void)doAlarmAnimation{
    CABasicAnimation* borderColorAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderColorAnimation.fromValue = (id)[UIColor clearColor].CGColor;
    borderColorAnimation.toValue = (id)[UIColor redColor].CGColor;
    borderColorAnimation.duration = 0.5;
    borderColorAnimation.autoreverses = true;
    borderColorAnimation.repeatCount = INFINITY;
    [self.cashDrawerButton.layer addAnimation:borderColorAnimation forKey:@"color and width"];
}



@end
