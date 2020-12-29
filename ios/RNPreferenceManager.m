
#import "RNPreferenceManager.h"
#import <React/RCTConvert.h>

// RNPreferenceSingleton : 多开下. 单一数据处理
@interface RNPreferenceSingleton : NSObject
+ (instancetype)shareInstance;
@property (copy, nonatomic) NSDictionary *singlePerference;
@property (copy, nonatomic) NSArray *whiteList;
@end

@implementation RNPreferenceSingleton
static RNPreferenceSingleton *_instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [RNPreferenceSingleton new];
        _instance.singlePerference = RCTJSONParse([RNPreferenceManager getPreferences], nil);
    });
    return _instance;
}
@end




static NSString *const kSHMPreferenceWhiteListChangedNotification = @"SHMPreferenceWhiteListChanged";
NSString *const PREFERENCE_KEY = @"RNPreferenceKey";

@implementation RNPreferenceManager

- (NSArray<NSString *> *)supportedEvents {
    return @[kSHMPreferenceWhiteListChangedNotification];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [RNPreferenceSingleton shareInstance];
    }
    return self;
}

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

RCT_EXPORT_METHOD(set:(NSString *)data
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    if (![RNPreferenceSingleton shareInstance].whiteList.count) {
        NSLog(@"未设置白名单!");
    }
    
    id obj = RCTJSONParse(data, nil);
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dicNew = obj;
        NSDictionary *dicOld = [RNPreferenceSingleton shareInstance].singlePerference;
        // 1. perfernce整体是否相等
        if (![dicNew isEqualToDictionary:dicOld]) {
            // 2. 取whitelist
            [[RNPreferenceSingleton shareInstance].whiteList enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *strNew = [dicNew[key] stringValue];
                NSString *strOld = [dicOld[key] stringValue];
                if (![strNew isEqualToString:strOld]) {
                    //3. js emitter 通知其他window
                    NSDictionary *item = @{key: strNew};
                    NSLog(@"item Changed : %@",item);
                    [self sendEventWithName:kSHMPreferenceWhiteListChangedNotification body:@{key: strNew}];
                }
            }];
                        
            //4. setSingleton , setUD
            [RNPreferenceSingleton shareInstance].singlePerference = obj;
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:PREFERENCE_KEY];
        }
    }
    resolve([RNPreferenceManager getPreferences]);
}

RCT_EXPORT_METHOD(clear:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFERENCE_KEY];
    resolve([RNPreferenceManager getPreferences]);
}

RCT_EXPORT_METHOD(setWhiteList:(NSArray *)whiteList) {
    NSLog(@" whitelist : %@",whiteList);
    [RNPreferenceSingleton shareInstance].whiteList = whiteList;
}

+ (NSString *)getPreferences
{
    NSString *preferences = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCE_KEY];
    return preferences ? preferences : @"{}";
}

+ (id)getPreference:(NSString *)key
{
    id object = RCTJSONParse([RNPreferenceManager getPreferences], nil);
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = object;
        return dictionary[key];
    } else {
        return nil;
    }
}

- (NSDictionary *)constantsToExport
{
    return @{ @"InitialPreferences": [RNPreferenceManager getPreferences] };
}

@end




