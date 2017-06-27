
#import "RNPreferenceManager.h"

NSString *const PREFERENCE_KEY = @"RNPreferenceKey";

@implementation RNPreferenceManager

RCT_EXPORT_MODULE()


RCT_EXPORT_METHOD(set:(NSString *)data
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:PREFERENCE_KEY];
    resolve([self getPreferences]);
}

RCT_EXPORT_METHOD(clear:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFERENCE_KEY];
    resolve([self getPreferences]);
}

- (NSString *)getPreferences
{
    NSString *preferences = [[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCE_KEY];
    return preferences ? preferences : @"{}";
}

- (NSDictionary *)constantsToExport
{
    return @{ @"InitialPreferences": [self getPreferences] };
}

@end
