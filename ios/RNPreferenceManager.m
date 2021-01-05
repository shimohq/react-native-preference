#import <React/RCTConvert.h>
#import "RNPreferenceManager.h"


@implementation RNPreferenceManager
RCT_EXPORT_MODULE()
+ (BOOL)requiresMainQueueSetup { return YES; }
- (NSArray<NSString *> *)supportedEvents { return @[kSHMPreferenceChangedNotification];}
- (instancetype)init {
    self = [super init];
    if (self) {
        [RNPreferenceSingleton shareInstance];
    }
    return self;
}
- (void)startObserving {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(perferenceChanged:) name:kSHMPreferenceChangedNotification object:nil];
}
- (void)stopObserving {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSHMPreferenceChangedNotification object:nil];
}
- (void)perferenceChanged:(NSNotification *)notification {
    [self sendEventWithName:kSHMPreferenceChangedNotification body:notification.object];
}


RCT_EXPORT_METHOD(set:(NSString *)data
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [[RNPreferenceSingleton shareInstance] setPreferenceData:data];
    resolve([RNPreferenceSingleton getAllPreferences]);
}

RCT_EXPORT_METHOD(clear:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    [[RNPreferenceSingleton shareInstance] clear];
    resolve([RNPreferenceSingleton getAllPreferences]);
}

RCT_EXPORT_METHOD(getPreferenceForKey:(NSString *)key
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    resolve( [[RNPreferenceSingleton shareInstance] getPreferenceValueForKey:key] );
}

RCT_EXPORT_METHOD(setWhiteList:(NSArray *)whiteList) {
    //NSLog(@"---- set whitelist : %@",whiteList);
    [RNPreferenceSingleton shareInstance].whiteList = whiteList;
}

- (NSDictionary *)constantsToExport {
    return @{ @"InitialPreferences": [RNPreferenceSingleton getAllPreferences] };
}

@end




