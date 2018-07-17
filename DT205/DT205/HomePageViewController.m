//
//  HomePageViewController.m
//  
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
#import "TcpSocket.h"
#import "UdpSocket.h"


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
    
    TcpSocket* tcpScoket;
    UdpSocket* udpSocket;
    BOOL use_Wifi;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    use_Wifi = [[NSUserDefaults standardUserDefaults]boolForKey:@"Use_Wifi"];
    use_Wifi = false;
    if (use_Wifi) {
        tcpScoket = [[TcpSocket alloc]init];
        udpSocket = [[UdpSocket alloc]init];
    }else{
        ble_Helper = [BLE_Helper sharedInstance];
    }
    audioPlayerManager = [AVAudioPlayerManager new];
    localNotificationHelper = [LocalNotificationHelper new];
    command = [GNTCommad new];
    isCommandOpenCashDrawer = false;
    
    
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(bindPasswordAlert)];
    longPress.minimumPressDuration = 1.0;
    [self.bindButton addGestureRecognizer:longPress];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ROOTVIEWCONTROLLER];
    
    [self getAppVersion];
}


- (void)getAppVersion {
    //To get the version number
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * versionBuildString = [NSString stringWithFormat:@"APP v%@.%@, SDK v", appVersionString, appBuildString];
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
    self.statusLabel.text = @"Disconnect";
    [self handleViewController];
    
    [[self.cashDrawerButton layer] setMasksToBounds:YES];
    [[self.cashDrawerButton layer] setBorderWidth:10.0f];
//    [[self.cashDrawerButton layer] setCornerRadius:self.cashDrawerButton.frame.size.width/1.0f];
    [[self.cashDrawerButton layer] setCornerRadius:155];
    [[self.cashDrawerButton layer] setBorderColor:[UIColor whiteColor].CGColor];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallbackData" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotifyCharacteristic" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BLE_PowerOff" object:nil];
    
    if (!use_Wifi) {
        [ble_Helper cancelPeripheral];
    }
    
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
    if (!use_Wifi) {
        [ble_Helper cancelPeripheral];
    }
    CentralModeTableViewController* scanVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CentralModeTableViewController"];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PASSWORD];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:DEVICE_UUID_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:false forKey:DEVICE_ISCONNECT];
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self presentViewController:scanVC animated:YES completion:nil];
}
- (IBAction)openCashDrawer:(id)sender {
    isCommandOpenCashDrawer = YES;
    if (use_Wifi) {
        [tcpScoket writeData:[command sendCommed:DEVICE_OPENCASHDRAWER Parameter:(char)DEVICE_OPENCASHDRAWER_PARAMETER]];
    }else{
        if (((int)(rssi*-30) < [ble_Helper readRSSI])) {
            [ble_Helper writeValue:[command sendCommed:DEVICE_OPENCASHDRAWER Parameter:(char)DEVICE_OPENCASHDRAWER_PARAMETER]];
        }else{
            [self showAlertWithMessage: @"Distance is too far"];
        }
    }
    
}
-(void)markCMDtoSendbyData:(NSData*)cmd{
    
    NSLog(use_Wifi ? @"use_Wifi = Yes" : @"use_Wifi = No");
    if (use_Wifi) {
        [tcpScoket writeData:cmd];
    }else{
        if(ble_Helper != nil) {
            [ble_Helper writeValue:cmd];
        }
    }
    
}
-(void)markDT205CMDtoSend:(char)cmd Parameter:(NSData*)parameter{
    
    
    NSData* buffCMD = [command creatCommandbyData:cmd Parameter:parameter];
    
    [self markCMDtoSendbyData:buffCMD];
}
-(void)cmdSetSetting:(NSString*)Address :(NSString*) Value{

    
    
    NSString* cmdBuff = [NSString stringWithFormat:@"%@,%@", Address, Value];
    
    NSMutableData* data = [cmdBuff dataUsingEncoding: NSUTF8StringEncoding];
    
    [self markDT205CMDtoSend:DT205_SETSETTING Parameter:[self addChecksum:data]];
}

-(NSMutableData*)addChecksum:(NSMutableData*)data{
    NSMutableData* cData = [[NSMutableData alloc]init];
    if (data != nil) {
        const char cmdSetting = (char)DT205_SETSETTING;
        [cData appendBytes:&cmdSetting length:1];
        [cData appendData:data];
        int iSum=0;
        [cData increaseLengthBy:2];
        char *m_bBuffer = (char*)[cData bytes];
        int iLen = [cData length];
        for(int i=0; i<iLen ;i++) {
            iSum=((iSum+m_bBuffer[i]) & 0x0FF);
        }
        
        m_bBuffer[iLen - 2] = (char)((iSum>>4) & 0x0F);
        m_bBuffer[iLen - 1] = (char)(iSum & 0x0F);
        for (int i = 0; i<2; i++) {
            if(m_bBuffer[iLen - 1 - i]<10){
                m_bBuffer[iLen - 1 - i]|=0x30;
            }else {
                m_bBuffer[iLen - 1 - i]+=(0x41-10);
            }
        }
        cData = [NSData dataWithBytes:m_bBuffer length:iLen];
        data = [cData subdataWithRange:NSMakeRange(1, iLen-1)];
    }
    return data;
}

-(void)cmdSetSensorType:(bool)isNormal{
    [self cmdSetSetting:@"00" :isNormal?@"00":@"FF"];
}

-(void)cmdSetSensorEnable:(bool)isEnable{
    [self cmdSetSetting:@"01" :isEnable?@"00":@"FF"];
}
-(void)cmdUpdateSettingChanges{
    [self markDT205CMDtoSend:DT205_UPDATESETTINGCHANGES Parameter:nil];
}

- (IBAction)changeBoxSize:(id)sender {
    if ([sender isOn]) {
        [self cmdSetSensorType:true];
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(cmdUpdateSettingChanges)
                                       userInfo:nil
                                        repeats:NO];
    }else {
        [self cmdSetSensorType:false];
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(cmdUpdateSettingChanges)
                                       userInfo:nil
                                        repeats:NO];
    }
    
    
}
#pragma mark - HandleData Metods

-(void)aaaaaa{
    
    NSLog(@"aaaaaa %@",ble_Helper.callBackDataBuffer);
    NSString* aaa = [NSString stringWithFormat:@"%@",ble_Helper.callBackDataBuffer];
    NSString* bbb = [aaa stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString* ccc = [bbb stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    unsigned char *cccc = (unsigned char*)[[ccc uppercaseString] UTF8String];
    
    
    [ble_Helper writeValue:[command sendCommed:'P' Parameter:cccc]];
    
}



-(void)handleViewController{
    self.statusView.backgroundColor = [UIColor greenColor];
    self.statusLabel.text = @"Connect";
    if (use_Wifi) {
        
        NSString* udpbracoast = @"Y";
        NSData* commandData = [udpbracoast dataUsingEncoding:NSUTF8StringEncoding];
        [udpSocket sendData:commandData toHost:@"255.255.255.255" port:65535 withTimeout:-1 tag:1];
        
        [tcpScoket connectToHost:self.device_IP Port:self.device_Port];
        [tcpScoket writeData:[command sendCommed:DEVICE_GET_NAME]];
        //[tcpScoket writeData:[command sendCommed:DEVICE_GET_STATUS Parameter:(char*)DEVICE_OPENCASHDRAWER_PARAMETER]];
        //  [tcpScoket writeData:[command sendCommed:DEVICE_GET_VERSION]];
    }else{
        //        NSString* aaa = @"ffeowifjweoifjweoifjweoijfeowi";
        //        NSData * sddsadas = [[NSData alloc]initWithBase64EncodedString:aaa options:NSDataBase64DecodingIgnoreUnknownCharacters];
        //        [ble_Helper writeValue:sddsadas];
        [ble_Helper writeValue:[command sendCommed:DEVICE_GET_NAME]];
        
        //  [ble_Helper writeValue:[command sendCommed:DEVICE_GET_STATUS Parameter:(char*)DEVICE_OPENCASHDRAWER_PARAMETER]];
        // [ble_Helper writeValue:[command sendCommed:DEVICE_GET_VERSION]];
    }
    
}
-(void)recieveUpdateValueFromCharacteristic{
    
    NSString* displayLabel;
    
    if (use_Wifi) {
        displayLabel = [[NSString alloc]initWithData:command.callBackDataBuffer encoding:NSUTF8StringEncoding];
    }else{
        displayLabel = [[NSString alloc]initWithData:ble_Helper.callBackDataBuffer encoding:NSUTF8StringEncoding];
    }
    
    NSLog(@"Gianni recieveUpdateValueFromCharacteristic displayLabel: %@", displayLabel);
    //
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

@end