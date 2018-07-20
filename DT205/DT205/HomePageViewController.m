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


@interface HomePageViewController () <DT205CommandV1CallBack>
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
    DT205* dt205;
    
    float rssi;
    BOOL isCommandOpenCashDrawer;
    //AVAudioPlayer
    AVAudioPlayerManager* audioPlayerManager;
    //Push LocalNotificationMessage
    LocalNotificationHelper* localNotificationHelper;
    
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
    
    [self getAppVersion];
    
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(refreshUI)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)refreshUI{
    if (dt205 != nil) {
        NSLog(@"dt205.getDeviceName %@", dt205.getDeviceName);
        NSLog(@"dt205.getBLEConnectState %@", dt205.getBLEConnectState);
        self.deviceNameLabel.text = dt205.getDeviceName;
        self.statusLabel.text = dt205.getBLEConnectState;
    }
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(refreshUI)
                                   userInfo:nil
                                    repeats:NO];
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recieveUpdateValueFromCharacteristic) name:@"CallbackData" object:nil];
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
        }else{
            [self showAlertWithMessage: @"Distance is too far"];
        }
    }
}


- (IBAction)changeBoxSize:(id)sender {
    if ([sender isOn]) {
        [dt205 cmdSetSensorType:true];
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(cmdUpdateSettingChanges)
                                       userInfo:nil
                                        repeats:NO];
    }else {
        [dt205 cmdSetSensorType:false];
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(cmdUpdateSettingChanges)
                                       userInfo:nil
                                        repeats:NO];
    }
    
    
}
-(void)cmdUpdateSettingChanges{
    [dt205 cmdUpdateSettingChanges];
}
#pragma mark - HandleData Metods





-(void)handleViewController{
    self.statusView.backgroundColor = [UIColor greenColor];
//    self.statusLabel.text = @"Connect";
    
    
    
    if (use_Wifi) {
        
        NSString* udpbracoast = @"Y";
        NSData* commandData = [udpbracoast dataUsingEncoding:NSUTF8StringEncoding];
//        [udpSocket sendData:commandData toHost:@"255.255.255.255" port:65535 withTimeout:-1 tag:1];
        
//        [tcpScoket connectToHost:self.device_IP Port:self.device_Port];
//        [tcpScoket writeData:[command sendCommed:DEVICE_GET_NAME]];
    }else{
        if (dt205 != nil) {
//            [dt205 startToScanBLEDevice];
        }
//         [dt205 cmdUpdateSettingChanges];
//        [ble_Helper writeValue:[command sendCommed:DEVICE_GET_NAME]];
    }
    
}
-(void)recieveUpdateValueFromCharacteristic{
    
    NSString* displayLabel;
    
    if (use_Wifi) {
//        displayLabel = [[NSString alloc]initWithData:command.callBackDataBuffer encoding:NSUTF8StringEncoding];
    }else{
//        displayLabel = [[NSString alloc]initWithData:ble_Helper.callBackDataBuffer encoding:NSUTF8StringEncoding];
        displayLabel = @"";
    }
    
    NSLog(@"Gianni recieveUpdateValueFromCharacteristic displayLabel: %@", displayLabel);
    if ([displayLabel isEqualToString:@"*c00"]) {
        [self.cashDrawerButton.layer removeAllAnimations];
        [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Close"] forState:UIControlStateNormal];
        [[self.cashDrawerButton layer]setBorderColor:[UIColor greenColor].CGColor];
        isCommandOpenCashDrawer = false;
        if (audioPlayerManager != nil) {
            [audioPlayerManager stop];
        }
        return;
    }else if ([displayLabel isEqualToString:@"*c01"]){
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
    }else if ([displayLabel isEqualToString:@"*r01"]){
        [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Open"] forState:UIControlStateNormal];
        
        [self doAlarmAnimation];
        [localNotificationHelper pushLocalNotificationMessageTitle:@"Notice" Body:@"Cash drawer is opened illegal"];
        
        return;
    }else if ([displayLabel isEqualToString:@"*a01"]){
        [self.cashDrawerButton setImage:[UIImage imageNamed:@"CashDrawer Open"] forState:UIControlStateNormal];
        
        [self doAlarmAnimation];
        [localNotificationHelper pushLocalNotificationMessageTitle:@"Notice" Body:@"Cash drawer is opened illegal"];
        
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


- (void)didUpdateBLEConnectionState:(NSString *)State{
    self.statusLabel.text = State;
}

- (void)didCMD_GetSensorType:(bool)isNormal{
    NSLog(@"didCMD_GetSensorType isNormal = %@", isNormal);
}

- (void)didCMD_General_Success:(NSString *)CMDName{
    NSLog(@"didCMD_General_Success CMDName = %@", CMDName);
}




@end
