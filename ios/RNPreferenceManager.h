#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RNPreferenceManager : RCTEventEmitter <RCTBridgeModule>
+ (id)getPreference:(NSString *)key;
+ (NSString *)getPreferences;
@end
