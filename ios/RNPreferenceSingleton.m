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
        self.singlePerference = dic ? [dic mutableCopy] : [@{} mutableCopy];
    }
    return self;
}

+ (NSString *)getAllPreferences {
    NSString *preferences = [[NSUserDefaults standardUserDefaults] stringForKey:kSHMPreferenceKey];
    return preferences ? preferences : @"{}";
}

- (NSString *)getPreferenceValueForKey:(NSString *)key {
    return self.singlePerference[key];
}

- (void)setJSPreferenceChangedDataString:(NSString *)jsonStr {
    NSDictionary *dicChanged = RCTJSONParse(jsonStr, nil);
    for (NSString *key in dicChanged.allKeys) {
        id value = dicChanged[key];
        [self setPreferenceValue:value forKey:key];
    }
}

- (void)clear {
    if (!self.singlePerference.allKeys.count) return;
        
    [[NSNotificationCenter defaultCenter] postNotificationName:kSHMPreferenceClearNotification object:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSHMPreferenceKey];
    self.singlePerference = [@{} mutableCopy];
}

- (void)clearValueForKey:(NSString *)key {
    if (![self.singlePerference.allKeys containsObject:key]) return;
    
    if ([self.whiteList containsObject:key]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSHMPreferenceClearNotification object:key];
    }
    [self.singlePerference removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:RCTJSONStringify(self.singlePerference, nil) forKey:kSHMPreferenceKey];
}


- (void)setPreferenceValue:(id)value forKey:(NSString *)key {
    if (!value || [value isKindOfClass:NSNull.class]) {
        // value is null , clear key .
        [self clearValueForKey:key];
        
        return;
    }

    NSMutableDictionary *dicNew = [self.singlePerference mutableCopy];
    [dicNew setObject:value forKey:key];
    
    if (![RNPreferenceSingleton shareInstance].whiteList.count) NSLog(@"RNPreference - white list is nil !");
    
    // Diff
    if (![value isEqual:self.singlePerference[key]]) {
        if ([self.whiteList containsObject:key]) {
            // in white list
            NSDictionary *item = @{key:value};
            NSLog(@"native RNPreference Changed : %@",item);
            [[NSNotificationCenter defaultCenter] postNotificationName:kSHMPreferenceChangedNotification object:item];
        }
    }
    // set Singleton , set UD
    [[NSUserDefaults standardUserDefaults] setObject:RCTJSONStringify(dicNew, nil) forKey:kSHMPreferenceKey];
    [self.singlePerference setObject:value forKey:key];
}


@end
