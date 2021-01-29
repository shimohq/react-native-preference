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

@property (strong, nonatomic) NSMutableDictionary *singlePreference;
@property (copy, nonatomic) NSArray *whiteList;

// Get
+ (NSString *)getAllPreferences;
- (id)getPreferenceValueForKey:(NSString *)key;
- (id)getPreferenceValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

// Set
///JS set Preference Changed Data
///@param jsonStr {key:value,....}
- (void)setJSPreferenceChangedDataString:(NSString *)jsonStr;
///set Preference value for key
- (void)setPreferenceValue:(id)value forKey:(NSString *)key;

// Clear
- (void)clear;
- (void)clearValueForKey:(NSString *)key;
@end


