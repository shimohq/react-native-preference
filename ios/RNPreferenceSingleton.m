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

@interface RNPreferenceSingleton()
@property (strong, nonatomic) NSMutableDictionary *singlePreference;
@end

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
        NSString *preferences = [self getUserDefaults];
        NSDictionary *dic = preferences ? RCTJSONParse(preferences, nil) : nil;
        self.singlePreference = dic ? [dic mutableCopy] : [@{} mutableCopy];
    }
    return self;
}

- (id)getPreferenceValueForKey:(NSString *)key {
    return self.singlePreference[key];
}

- (id)getPreferenceValueForKey:(NSString *)key defaultValue:(id)defaultValue {
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
    
    self.singlePreference = [@{} mutableCopy];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSHMPreferenceClearNotification object:nil];
    
    [self syncUserDefaults];
}

- (void)clearValueForKey:(NSString *)key {
    if (![self.singlePreference.allKeys containsObject:key]) return;
    
    [self.singlePreference removeObjectForKey:key];
    
    if ([self.whiteList containsObject:key]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSHMPreferenceClearNotification object:@{@"key":key}];
    }
    
    [self syncUserDefaults];
}

- (void)setPreferenceValue:(id)value forKey:(NSString *)key {
    if (!value || [value isKindOfClass:NSNull.class]) {
        // value is null , clear key .
        [self clearValueForKey:key];
        return;
    }

    if ([value isEqual:self.singlePreference[key]]) {
        return;
    }
    
    [self.singlePreference setObject:value forKey:key];
    
    if ([self.whiteList containsObject:key]) {
        NSDictionary *item = @{key:value};
        NSLog(@"native RNPreference Changed: key: %@, value: %@", key, value);
        [[NSNotificationCenter defaultCenter] postNotificationName:kSHMPreferenceChangedNotification object:item];
    }
    
    [self syncUserDefaults];
}

#pragma mark - NSUserDefaults

- (NSString *)getUserDefaults {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kSHMPreferenceKey];
}

- (void)syncUserDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:RCTJSONStringify(self.singlePreference, nil) forKey:kSHMPreferenceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
