//
//  SceneDelegate.m
//  TestDemo
//
//  Created by teason23 on 2020/12/31.
//

#import "SceneDelegate.h"
#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTBridgeDelegate.h>

#import "AppDelegate.h"
#import "RootVC.h"

@implementation SceneDelegate

#pragma mark - UISceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  API_AVAILABLE(ios(13.0)){
    
  AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
  NSURL *jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"
                                                                         fallbackResource:nil];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"TestDemo"
                                               initialProperties:nil
                                                   launchOptions:appDelegate.launchOptions];
  
  UIWindowScene *windowScene = (UIWindowScene *)scene;  
  UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
  RootVC *rootViewController = [[RootVC alloc] init];
  rootViewController.view = rootView;
  window.rootViewController = rootViewController;
  [window makeKeyAndVisible];
  self.window = window;
  [appDelegate setWindow:self.window];
}

- (void)sceneDidDisconnect:(UIScene *)scene  API_AVAILABLE(ios(13.0)){

}

- (void)sceneDidBecomeActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){

}

- (void)sceneWillResignActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    
}

- (void)sceneWillEnterForeground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    
}

- (void)sceneDidEnterBackground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    
}

- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity  API_AVAILABLE(ios(13.0)){
    
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts  API_AVAILABLE(ios(13.0)){
    
}

@end
