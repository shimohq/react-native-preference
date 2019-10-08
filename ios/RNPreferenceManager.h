#import <React/RCTBridgeModule.h>

@interface RNPreferenceManager : NSObject <RCTBridgeModule>

+ (id)getPreference:(NSString *)key;

@end
