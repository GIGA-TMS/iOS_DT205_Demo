//
//  AVAudioPlayerManager.m
//  HelloMyBLE
//
//  Created by wilson on 2017/5/12.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import "AVAudioPlayerManager.h"
#import <UIKit/UIKit.h>
@implementation AVAudioPlayerManager
{
    AVAudioPlayer* soundsPlayer;
}
-(void)playSoundsName:(NSString*)soundName Repeat:(int)repeat{
    NSURL* fileURL = [[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
    if (fileURL != nil) {
        NSError* error;
        soundsPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:&error];
        NSLog(@"%@",soundsPlayer);
        if (repeat == 0) {
            //無限次
            soundsPlayer.numberOfLoops = -1;
        }else{
            soundsPlayer.numberOfLoops = repeat - 1;
        }
        [soundsPlayer prepareToPlay];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
        [soundsPlayer play];
    }
}
-(void)stop{
    [soundsPlayer stop];
}
@end
