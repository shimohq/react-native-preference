//
//  RNPreferenceSingleton.m
//  RNPreferenceManager
//
//  Created by teason23 on 2020/12/30.
//  Copyright © 2020 shimo. All rights reserved.
//

#import "RNPreferenceSingleton.h"
#import "RNPreferenceManager.h"
#import <React/RCTConvert.h>

NSString *const kSHMPreferenceKey = @"RNPreferenceKey";
NSString *const kSHMPreferenceChangedNotification = @"SHMPreference_WhiteList_Notification";
NSString *const kSHMPreferenceClearNotification = @"SHMPreference_Clear_Notification";

@implementation RNPreferenceSingleton
static RNPreferenceSingleton *_instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[RNPreferenceSingleton alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSDictionary *dic = RCTJSONParse([RNPreferenceSingleton getAllPreferences], nil);
        self.singlePreference = dic ? [dic mutableCopy] : [@{} mutableCopy];
    }
    return self;
}

+ (NSString *)getAllPreferences {
    NSString *preferences = [[NSUserDefaults standardUserDefaults] stringForKey:kSHMPreferenceKey];
    return preferences ? preferences : @"{}";
}

- (id)getPreferenceValueForKey:(NSString *)key {
    return self.singlePreference[key];
}

- (id)getPreferenceValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    id value = [self getPreferenceValueForKey:key];
    if (value == nil) {
        value = defaultValue;
    }
    return value;
}

- (void)setJSPreferenceChangedDataString:(NSString *)jsonStr {
    NSDictionary *dicChanged = RCTJSONParse(jsonStr, nil);
    for (NSString *key in dicChanged.allKeys) {
        id value = dicChanged[key];
        [self setPreferenceValue:value forKey:key];
    }
}

- (void)clear {
    if (!self.singlePreference.allKeys.count) return;
        
    [[NSNotificationCenter defaultCenter] postNotificationName:kSHMPreferenceClearNotification object:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSHMPreferenceKey];
    self.singlePreference = [@{} mutableCopy];
}

- (void)clearValueForKey:(NSString *)key {
    if (![self.singlePreference.allKeys containsObject:key]) return;
    
    if ([self.whiteList containsObject:key]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSHMPreferenceClearNotification object:@{@"key":key}];
    }
    [self.singlePreference removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:RCTJSONStringify(self.singlePreference, nil) forKey:kSHMPreferenceKey];
}


- (void)setPreferenceValue:(id)value forKey:(NSString *)key {
    if (!value || [value isKindOfClass:NSNull.class]) {
        // value is null , clear key .
        [self clearValueForKey:key];
        
        return;
    }

    NSMutableDictionary *dicNew = [self.singlePreference mutableCopy];
    [dicNew setObject:value forKey:key];
    
    if (![RNPreferenceSingleton shareInstance].whiteList.count) NSLog(@"RNPreference - white list is nil !");
    
    // Diff
    if (![value isEqual:self.singlePreference[key]]) {
        if ([self.whiteList containsObject:key]) {
            // in white list
            NSDictionary *item = @{key:value};
            NSLog(@"native RNPreference Changed : %@",item);
            [[NSNotificationCenter defaultCenter] postNotificationName:kSHMPreferenceChangedNotification object:item];
        }
    }
    // set Singleton , set UD
    [[NSUserDefaults standardUserDefaults] setObject:RCTJSONStringify(dicNew, nil) forKey:kSHMPreferenceKey];
    [self.singlePreference setObject:value forKey:key];
}

@end
