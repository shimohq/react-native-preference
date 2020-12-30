//
//  RNPreferenceSingleton.h
//  RNPreferenceManager
//
//  Created by teason23 on 2020/12/30.
//  Copyright © 2020 shimo. All rights reserved.
// RNPreferenceSingleton : 多开下. 单一数据处理
//

#import <Foundation/Foundation.h>

extern NSString *const kSHMPreferenceKey;
extern NSString *const kSHMPreferenceChangedNotification;

@interface RNPreferenceSingleton : NSObject
+ (instancetype)shareInstance;

@property (copy, nonatomic) NSDictionary *singlePerference;
@property (copy, nonatomic) NSArray *whiteList;

+ (NSString *)getAllPreferences;
- (NSString *)getPreferenceValueForKey:(NSString *)key;
- (void)setPreferenceValue:(NSString *)value forKey:(NSString *)key;
- (void)setPreferenceData:(NSString *)data;
- (void)clear;
@end


