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
#import "AVAudioPlayerManager.h"
#import "LocalNotificationHelper.h"

#import "BLE_Helper.h"

@interface HomePageViewController ()
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
    //BLE
    BLE_Helper* ble_Helper;
    //Send Command
    GNTCommad* command;
    float rssi;
    BOOL isCommandOpenCashDrawer;
    //AVAudioPlayer
    AVAudioPlayerManager* audioPlayerManager;
    //Push LocalNotificationMessage
    LocalNotificationHelper* localNotificationHelper;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    audioPlayerManager = [AVAudioPlayerManager new];
    localNotificationHelper = [LocalNotificationHelper new];
    ble_Helper = [BLE_Helper sharedInstance];
    command = [GNTCommad new];
    isCommandOpenCashDrawer = false;
    
    NSUUID* uuid =[[UIDevice currentDevice] identifierForVendor];
    NSLog(@"%@",uuid);
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(bindPasswordAlert)];
    longPress.minimumPressDuration = 1.0;
    [self.bindButton addGestureRecognizer:longPress];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ROOTVIEWCONTROLLER];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recieveUpdateValueFromCharacteristic) name:@"CallbackData" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleViewController) name:@"NotifyCharacteristic" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(powerOff_BLE) name:@"BLE_PowerOff" object:nil];
    
    self.statusView.backgroundColor = [UIColor redColor];
    self.statusLabel.text = @"Disconnect";
    [self handleViewController];
    
    [[self.cashDrawerButton layer] setMasksToBounds:YES];
    [[self.cashDrawerButton layer] setBorderWidth:6.0f];
    [[self.cashDrawerButton layer] setCornerRadius:self.cashDrawerButton.frame.size.height/2.0f];
    [[self.cashDrawerButton layer] setBorderColor:[UIColor whiteColor].CGColor];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallbackData" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotifyCharacteristic" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BLE_PowerOff" object:nil];
    
    [ble_Helper cancelPeripheral];
}

-(void)powerOff_BLE{
    self.statusView.backgroundColor = [UIColor redColor];
    self.statusLabel.text = @"Disconnect";
    [self showAlertWithMessage:@"Please PowerOn Bletooth"];
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
    [ble_Helper cancelPeripheral];

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PASSWORD];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:DEVICE_UUID_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:false forKey:DEVICE_ISCONNECT];
    [self presentViewController:scanVC animated:YES completion:nil];
}
- (IBAction)openCashDrawer:(id)sender {
    isCommandOpenCashDrawer = YES;
    if (((int)(rssi*-30) < [ble_Helper readRSSI])) {
        [ble_Helper writeValue:[command sendCommed:DEVICE_OPENCASHDRAWER Parameter:(char*)DEVICE_OPENCASHDRAWER_PARAMETER]];
    }else{
        [self showAlertWithMessage: @"Distance is too far"];
    }
}
#pragma mark - HandleData Metods
-(void)handleViewController{
    self.statusView.backgroundColor = [UIColor greenColor];
    self.statusLabel.text = @"Connect";
    [ble_Helper writeValue:[command sendCommed:DEVICE_GET_NAME]];
    [ble_Helper writeValue:[command sendCommed:DEVICE_GET_STATUS Parameter:(char*)DEVICE_OPENCASHDRAWER_PARAMETER]];
    [ble_Helper writeValue:[command sendCommed:DEVICE_GET_VERSION]];
}
-(void)recieveUpdateValueFromCharacteristic{
    NSLog(@"%@",ble_Helper.callBackDataBuffer);
    NSString* displayLabel = [[NSString alloc]initWithData:ble_Helper.callBackDataBuffer encoding:NSUTF8StringEncoding];
    if ([displayLabel isEqualToString:@"*,00"]) {
        [self.cashDrawerButton.layer removeAllAnimations];
        [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Close"] forState:UIControlStateNormal];
        [[self.cashDrawerButton layer]setBorderColor:[UIColor greenColor].CGColor];
        isCommandOpenCashDrawer = false;
        if (audioPlayerManager != nil) {
            [audioPlayerManager stop];
        }
        return;
    }else if ([displayLabel isEqualToString:@"*,01"]){
        [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Open"] forState:UIControlStateNormal];
        if (!isCommandOpenCashDrawer) {
            [self doAlarmAnimation];
            [localNotificationHelper pushLocalNotificationMessageTitle:@"Notice" Body:@"Cash drawer is opened illegal"];
      }else{
            [[self.cashDrawerButton layer]setBorderColor:[UIColor greenColor].CGColor];
            [audioPlayerManager playSoundsName:@"CashDrawerOpen.wav" Repeat:1];
        }
        return;
    }else if ([displayLabel isEqualToString:@"A,00"]){
        [self.cashDrawerButton.layer removeAllAnimations];
        [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Close"] forState:UIControlStateNormal];
        [[self.cashDrawerButton layer]setBorderColor:[UIColor greenColor].CGColor];
        isCommandOpenCashDrawer = false;
        if (audioPlayerManager != nil) {
            [audioPlayerManager stop];
        }
        return;
    }else if ([displayLabel isEqualToString:@"A,01"]){
        [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Open"] forState:UIControlStateNormal];
        if (!isCommandOpenCashDrawer) {
            [self doAlarmAnimation];
            [localNotificationHelper pushLocalNotificationMessageTitle:@"Notice" Body:@"Cash drawer is opened illegal"];
        }else{
            [[self.cashDrawerButton layer]setBorderColor:[UIColor greenColor].CGColor];
            [audioPlayerManager playSoundsName:@"CashDrawerOpen.wav" Repeat:1];
        }
        return;
    }else if ([displayLabel containsString:@"A,ROM"]) {
        NSString* display = [displayLabel substringFromIndex:2];
        NSString* version = [NSString stringWithFormat:@"F/W Version:%@",display];
        self.deviceVersionLabel.text = version;
        return;
    }else if ([displayLabel containsString:@"A,DT"]){
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
    // 動畫結束後 不刪除動畫 --- 背景回來動畫還會繼續
    borderColorAnimation.removedOnCompletion = false;
    [audioPlayerManager playSoundsName:@"Alarm.mp3" Repeat:0];
    [self.cashDrawerButton.layer addAnimation:borderColorAnimation forKey:@"color and width"];
}
@end
