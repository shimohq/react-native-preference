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
    NSMutableDictionary *tmpDic = [self.singlePerference mutableCopy];
    
    NSDictionary *dicChanged = RCTJSONParse(jsonStr, nil);
    for (NSString *key in dicChanged.allKeys) {
        id value = dicChanged[key];
        
        if (!value || [value isKindOfClass:NSNull.class]) {
            // value is null , clear key
            [tmpDic removeObjectForKey:key];
            
            if ([self.whiteList containsObject:key]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kSHMPreferenceClearNotification object:key];
            }
        } else {
            [tmpDic setObject:value forKey:key];
            
            if ([self.whiteList containsObject:key]) {
                NSDictionary *item = @{key:value};
                NSLog(@"RNPreference js Changed : %@",item);
                [[NSNotificationCenter defaultCenter] postNotificationName:kSHMPreferenceChangedNotification object:item];
            }
        }
        
        // set SingletonData , set UD
        [[NSUserDefaults standardUserDefaults] setObject:RCTJSONStringify(tmpDic, nil) forKey:kSHMPreferenceKey];
        self.singlePerference = tmpDic;
    }
}

- (void)clear {
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


- (void)nativeSetPreferenceValue:(id)value
                          forKey:(NSString *)key {
    if (!value || [value isKindOfClass:NSNull.class]) {
        [self clearValueForKey:key];
        return;
    }

    NSMutableDictionary *dic = [self.singlePerference mutableCopy];
    [dic setObject:value forKey:key];
    
    if (![RNPreferenceSingleton shareInstance].whiteList.count) NSLog(@"RNPreference - white list is nil !");
    
    // Diff
    NSDictionary *dicNew = dic;
    NSDictionary *dicOld = [RNPreferenceSingleton shareInstance].singlePerference;
    // 1. perfernce整体是否相等
    if (![dicNew isEqualToDictionary:dicOld]) {
        // 2. 取whitelist
        [self.whiteList enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
            id valueNew = dicNew[key];
            id valueOld = dicOld[key];
                            
            if (![valueNew isEqual:valueOld]) {
                //3. data变化, 通知js
                NSDictionary *item = @{key: valueNew};
                NSLog(@"native RNPreference Changed : %@",item);
                [[NSNotificationCenter defaultCenter] postNotificationName:kSHMPreferenceChangedNotification object:item];
            }
        }];
    }
    
    // set Singleton , set UD
    [[NSUserDefaults standardUserDefaults] setObject:RCTJSONStringify(dicNew, nil) forKey:kSHMPreferenceKey];
    [self.singlePerference setObject:value forKey:key];
}


@end
