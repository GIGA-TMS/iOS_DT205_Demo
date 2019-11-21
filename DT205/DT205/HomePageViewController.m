//
//  HomePageViewController.m
//  
//
//  Created by wilson on 2017/4/14.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "HomePageViewController.h"
#import <DT205SDK/Header.h>
#import <DT205SDK/DT205.h>
#import "AVAudioPlayerManager.h"
#import "LocalNotificationHelper.h"
#import "ScanDeviceTableViewController.h"
#import "CustomPWDAlertView.h"
#import "CustomPWDAlertViewDelegate.h"


@interface HomePageViewController () <DT205CommandV1CallBack,CustomPWDAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIButton *bindButton;
@property (weak, nonatomic) IBOutlet UIButton *cashDrawerButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceVersionLabel;
@property (weak, nonatomic) IBOutlet UISlider *sliderRSSI;

@property (weak, nonatomic) IBOutlet UISwitch *swSensorType;
@property (weak, nonatomic) IBOutlet UISwitch *swSensorEanble;

@end

@implementation HomePageViewController
{
    DT205* dt205;
    BOOL isfirst;
    float rssi;
    BOOL isCommandOpenCashDrawer;
    //AVAudioPlayer
    AVAudioPlayerManager* audioPlayerManager;
    //Push LocalNotificationMessage
    LocalNotificationHelper* localNotificationHelper;
    NSString * strFWVersion;
    NSString * strContinuationCode;
    
    BOOL use_Wifi;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //    use_Wifi = [[NSUserDefaults standardUserDefaults]boolForKey:@"Use_Wifi"];
    use_Wifi = false;
    dt205 = [DT205 sharedInstance:use_Wifi];
    [dt205 setDt205Listener:self];
    
    audioPlayerManager = [AVAudioPlayerManager new];
    localNotificationHelper = [LocalNotificationHelper new];
    isCommandOpenCashDrawer = false;
    
    
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(bindPasswordAlert)];
    longPress.minimumPressDuration = 1.0;
    [self.bindButton addGestureRecognizer:longPress];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ROOTVIEWCONTROLLER];
    
    
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(refreshUI)
                                   userInfo:nil
                                    repeats:NO];
    
    
    isfirst = true;
    
}

-(void)refreshFWVerUI{
    if ([dt205.getBLEConnectState isEqualToString:@"Connected"]) {
        [dt205 cmdGetFWVersion];
        
    }
    isfirst = false;
}

-(void)refreshUI{
    if (dt205 != nil) {
        self.deviceNameLabel.text = dt205.getDeviceName;
        self.statusLabel.text = dt205.getBLEConnectState;
//        self.sliderRSSI.value = -1 * [dt205 readBLERSSI];
        if (isfirst) {
            
            [NSTimer scheduledTimerWithTimeInterval:1.5
                                             target:self
                                           selector:@selector(refreshFWVerUI)
                                           userInfo:nil
                                            repeats:NO];
        }
        
    }
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(refreshUI)
                                   userInfo:nil
                                    repeats:NO];
}




-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recieveUpdateValueFromCharacteristic) name:@"CallbackData" object:nil];
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(aaaaaa) name:@"CallbackData" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleViewController) name:@"NotifyCharacteristic" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(powerOff_BLE) name:@"BLE_PowerOff" object:nil];
    
    self.statusView.backgroundColor = [UIColor redColor];
    //    self.statusLabel.text = @"Disconnect";
    [self handleViewController];
    
    [[self.cashDrawerButton layer] setMasksToBounds:YES];
    [[self.cashDrawerButton layer] setBorderWidth:10.0f];
    [[self.cashDrawerButton layer] setCornerRadius:155];
    [[self.cashDrawerButton layer] setBorderColor:[UIColor whiteColor].CGColor];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallbackData" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotifyCharacteristic" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BLE_PowerOff" object:nil];
    
    if (!use_Wifi) {
    }
    
}

-(void)powerOff_BLE{
    self.statusView.backgroundColor = [UIColor redColor];
    //    self.statusLabel.text = @"Disconnect";
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
            [dt205 disconnectBLEDevice];
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
    if (!use_Wifi) {
        //        [ble_Helper cancelPeripheral];
    }
    ScanDeviceTableViewController* scanVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanDeviceTableViewController"];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PASSWORD];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:DEVICE_UUID_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:false forKey:DEVICE_ISCONNECT];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self presentViewController:scanVC animated:YES completion:nil];
}
- (IBAction)openCashDrawer:(id)sender {
    isCommandOpenCashDrawer = YES;
    if (use_Wifi) {
        [dt205 cmdCtrlTriggerToOpen];
    }else{
        if (((int)(rssi*-30) < [dt205 readBLERSSI])) {
            [dt205 cmdCtrlTriggerToOpen];
//            [dt205 cmdCtrlResetTriggerCounter];
        }else{
            [self showAlertWithMessage: @"Distance is too far"];
        }
    }
}


- (IBAction)changeBoxSize:(id)sender {
    [dt205 cmdSetSensorType:[sender isOn]];
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(cmdUpdateSettingChanges)
                                   userInfo:nil
                                    repeats:NO];
}

- (IBAction)alarmEanble:(id)sender {
    [dt205 cmdSetAlarm:[sender isOn]];
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(cmdUpdateSettingChanges)
                                   userInfo:nil
                                    repeats:NO];
    
}

-(void)cmdUpdateSettingChanges{
    [dt205 cmdUpdateSetting];
}
#pragma mark - HandleData Metods





-(void)handleViewController{
    self.statusView.backgroundColor = [UIColor greenColor];
    //    self.statusLabel.text = @"Connect";
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


- (void)didUpdateBLEConnectionState:(NSString *)State{
    self.statusLabel.text = State;
    
}

-(void)didUpdateBLECentralManagerState:(NSString*) State{
    
}
-(void)didCMD_General_Success:(NSString*) CMDName{
    NSLog(@"didCMD_General_Success CMDName = %@", CMDName);
//    if ([CMDName isEqualToString:@"CtrlTriggerToOpen"]) {
//        [dt205 cmdGetCashDrawerStatus];
//    }
}
-(void)didCMD_General_ERROR:(NSString*) CMDName errMassage:(NSString*) errMassage{
    
}
-(void)didCMD_Polling:(NSString*) ProductName LoginState:(NSData*)LoginState Random:(NSData*) Random{
    
}
-(void)didCMD_FW_Ver:(NSString*)fwName fwVer:(NSString*)fwVer{
    NSLog(@"didCMD_FW_Ver fwName = %@", fwName);
    strFWVersion = fwName;
    
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(cmdGetSensorType)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)cmdGetSensorType{
    [dt205 cmdGetSensorType];
}

-(void)cmdGetAlarm{
    [dt205 cmdGetAlarm];
}

-(void)cmdGetCashDrawerStatus{
    [dt205 cmdGetCashDrawerStatus];
}
-(void)didCMD_GetCashDrawerStatus:(bool) isOpen{
    NSLog(@"didCMD_GetCashDrawerStatus isOpen = %@", isOpen?@"Y":@"N");
    if (isOpen) {
        [self cashDrawerOpen];
    }else {
        [self cashDrawerClose];
    }
    
}
-(void)didCMD_GetUsageCounter:(NSString*) Count{
    
}


-(void)didCMD_GetSensorType:(bool) isNormal{
    NSLog(@"didCMD_GetSensorType isNormal = %@", isNormal?@"Y":@"N");
    [_swSensorType setOn:isNormal];
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(cmdGetAlarm)
                                   userInfo:nil
                                    repeats:NO];
}
-(void)didCMD_GetSensorEnable:(bool) isEnable{
    NSLog(@"didCMD_GetSensorEnable isNormal = %@", isEnable?@"Y":@"N");
    [_swSensorEanble setOn:isEnable];
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(cmdGetCashDrawerStatus)
                                   userInfo:nil
                                    repeats:NO];
}




- (void)didEvent_OpenAlert:(bool)isOpen{
    NSLog(@"didEvent_OpenAlert isOpen = %@", isOpen?@"Y":@"N");
    isCommandOpenCashDrawer = false;
    if (isOpen) {
        [self cashDrawerOpen];
    }else {
        [self cashDrawerClose];
    }
}

- (void)didEvent_OpenReminding:(bool)isOpen{
    NSLog(@"didEvent_OpenReminding isOpen = %@", isOpen?@"Y":@"N");
    isCommandOpenCashDrawer = false;
    if (isOpen) {
        [self cashDrawerOpen];
    }else {
        [self cashDrawerClose];
    }
}
- (void)didEvent_StatusChanged:(bool)isOpen{
    NSLog(@"didEvent_StatusChanged isOpen = %@", isOpen?@"Y":@"N");
    if (isOpen) {
        [self cashDrawerOpen];
    }else {
        [self cashDrawerClose];
    }

}

-(void)cashDrawerOpen{
    [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Open"] forState:UIControlStateNormal];
    if (!isCommandOpenCashDrawer) {
        [self doAlarmAnimation];
        [localNotificationHelper pushLocalNotificationMessageTitle:@"Notice" Body:@"Cash drawer is opened illegal"];
    }else{
        [[self.cashDrawerButton layer]setBorderColor:[UIColor greenColor].CGColor];
        [audioPlayerManager playSoundsName:@"CashDrawerOpen.wav" Repeat:1];
    }
}

-(void)cashDrawerClose{
    [self.cashDrawerButton.layer removeAllAnimations];
    [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Close"] forState:UIControlStateNormal];
    [[self.cashDrawerButton layer]setBorderColor:[UIColor greenColor].CGColor];
    isCommandOpenCashDrawer = false;
    if (audioPlayerManager != nil) {
        [audioPlayerManager stop];
    }

}
- (void)didCreateContinuationCode:(NSString *)code{
    strContinuationCode = code;
}

- (IBAction)btnAbout:(id)sender {
    [dt205 createContinuationCode];

    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * versionBuildString = [NSString stringWithFormat:@"APP Version: v%@.%@\n\nSDK Version: v%@", appVersionString, appBuildString, [dt205 getSDKVersion]];

    NSString * strFWVer = [NSString stringWithFormat:@"Firmware Version:%@", strFWVersion];

    NSString * strConCode = [NSString stringWithFormat:@"ContinuationCode:\n%@", strContinuationCode];
    NSString * message =  [NSString stringWithFormat:@"\n%@\n\n%@\n\n%@", versionBuildString, strFWVer, strConCode];


    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"About Information" message:message preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"BACK" style: UIAlertActionStyleCancel handler:nil];

    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:nil];
}

//CustomAlertView example by Gianni 2018/08/15
//- (IBAction)btnAbout:(id)sender {
//    CustomPWDAlertView* customAlert = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomPWDAlertID"];
//    customAlert.providesPresentationContextTransitionStyle = true;
//    customAlert.definesPresentationContext = true;
//    customAlert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    customAlert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    customAlert.pwdAlertViewDelegate = self;
//    [self presentViewController:customAlert animated:true completion:nil];
//}
//
//
//- (void)okButtonTapped:(NSString *)selectedOption :(NSString *)textPIN :(NSString *)textConfirmPIN :(NSString *)textContinuationCode{
//    NSLog(@"okButtonTapped with %@ option selected", selectedOption);
//    NSLog(@"TextField has value: %@", textPIN);
//}
//
//- (void)cancelButtonTapped{
//    NSLog(@"cancelButtonTapped");
//}


@end
