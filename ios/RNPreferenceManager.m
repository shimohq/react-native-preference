
#import "RNPreferenceManager.h"
#import <React/RCTConvert.h>

NSString *const PREFERENCE_KEY = @"RNPreferenceKey";

@implementation RNPreferenceManager

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

RCT_EXPORT_METHOD(set:(NSString *)data
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:PREFERENCE_KEY];
    resolve([RNPreferenceManager getPreferences]);
}

RCT_EXPORT_METHOD(clear:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFERENCE_KEY];
    resolve([RNPreferenceManager getPreferences]);
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
