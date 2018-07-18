//
//  TagInfo.h
//  TS800_Japan
//
//  Created by Gianni on 2017/8/8.
//  Copyright © 2017年 Gianni. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagInfo : NSObject
@property(nonatomic,strong) NSData* tagData;
@property(nonatomic,strong) NSData* epcTagName;
@property(nonatomic,strong) NSNumber* tagLength;
@property(nonatomic,strong) NSNumber* tidLength;
@property(nonatomic, assign) int  scanCount;
@end
