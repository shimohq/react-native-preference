//
//  RNPreferenceSingleton.h
//  RNPreferenceManager
//
//  Created by teason23 on 2020/12/30.
//  Copyright © 2020 shimo. All rights reserved.
// RNPreferenceSingleton : Preference单一数据处理
//

#import <Foundation/Foundation.h>

extern NSString *const kSHMPreferenceKey;
extern NSString *const kSHMPreferenceChangedNotification;
extern NSString *const kSHMPreferenceClearNotification;

@interface RNPreferenceSingleton : NSObject
+ (instancetype)shareInstance;

@property (strong, nonatomic) NSMutableDictionary *singlePerference;
@property (copy, nonatomic) NSArray *whiteList;

+ (NSString *)getAllPreferences;
- (NSString *)getPreferenceValueForKey:(NSString *)key;
- (void)setPreferenceValue:(NSString *)value forKey:(NSString *)key;
- (void)clear;
@end


