
#import "RNPreferenceManager.h"


@implementation RNPreferenceManager

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(set:(NSDictionary *)data
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    for (id key in data) {
        id value = [data objectForKey:key];
        
        if (value && ![value isKindOfClass:[NSNull class]]) {
            [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
    }
    resolve([self getPreferences]);
}

RCT_EXPORT_METHOD(clear:(NSArray *)keys
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    for(NSString *key in keys) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    
    resolve([self getPreferences]);
}

RCT_EXPORT_METHOD(clearAll:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    NSArray *keys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    [self clear:keys resolve:resolve reject:reject];
}

RCT_EXPORT_METHOD(sync:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    resolve([self getPreferences]);
}

- (NSDictionary *)getPreferences
{
    NSArray *keys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for(NSString *key in keys) {
        NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:key];
        
        if (value) {
            result[key] = value;
        }
    }
    
    return [result copy];
}

- (NSDictionary *)constantsToExport
{
    return @{ @"InitialPreferences": [self getPreferences] };
}

@end
