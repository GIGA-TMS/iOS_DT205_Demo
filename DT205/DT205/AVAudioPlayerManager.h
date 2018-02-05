//
//  AVAudioPlayerManager.h
//  
//
//  Created by wilson on 2017/5/12.
//  Copyright © 2017年 WilsonChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface AVAudioPlayerManager : NSObject

-(void)playSoundsName:(NSString*)soundName Repeat:(int)repeat;

-(void)stop;
@end
