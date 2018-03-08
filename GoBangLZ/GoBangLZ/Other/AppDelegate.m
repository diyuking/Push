//
//  AppDelegate.m
//  GoBangLZ
//
//  Created by k on 2018/2/23.
//  Copyright © 2018年 poor kid. All rights reserved.
//

#import "AppDelegate.h"
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#import <UserNotifications/UserNotifications.h>
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>
//友盟推送
#import "UMessage.h"
//pdf
#import "PDFReaViewController.h"


@interface AppDelegate ()<UNUserNotificationCenterDelegate>

#define    JPUSHKEY @""
#define    UMessageAppKey @""
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *dict = @{@"key":@"value",@"key2":@"value"};
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"keyYrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Override point for customization after application launch.
    //极光
//    [self jPshNotificenterWithApplication:application lauchOptionsDic:launchOptions];
    //友盟
    [self configureUMessageWithLaunchOptions:launchOptions];
    //ios自带推送
//    [self addpushNotification];
//    PDFReaViewController *pdfVC = [[PDFReaViewController alloc] init];
//    UINavigationController *nacVC = [[UINavigationController alloc] initWithRootViewController:pdfVC];
//    self.window.rootViewController = nacVC;
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyWindow];
//    [self.window makeKeyAndVisible];
    
    return YES;
}
#pragma  mark - 自带推送
/*- (void)addpushNotification
{
    if(@available(iOS 8.0, *))
    {
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        //注册通知类型
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 申请试用通知
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
}
 #pragma mark - 获取到用户对应应用程序的deviceToken时会调用
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *tokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *tokenIdString = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"tokenIdString:%s     %@",__func__,tokenIdString);
}
#pragma mark - 接收到原创通知时就会调用
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if(application.applicationState == UIApplicationStateActive)return;
    
}
- (void)remoteActionWithDict:(NSDictionary *)userInfo
{
    NSLog(@"%s %@",__func__,userInfo);
}*/
#pragma mark - 友盟推送
- (void)configureUMessageWithLaunchOptions:(NSDictionary *)lauchDic
{
    [UMessage startWithAppkey:UMessageAppKey launchOptions:lauchDic];
    [UMessage registerForRemoteNotifications];
    //ios10必须加下面的这段代码
//    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        UNAuthorizationOptions types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        [center requestAuthorizationWithOptions:types completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if(granted)
            {
                //点击允许 添加一些自己的逻辑
            }else
            {
                //点击不允许 添加一些自己的逻辑
                
            }
        }];
        //打开日志 方便调试
        [UMessage setLogEnabled:YES];
//    } else {
//        // Fallback on earlier versions
//    }
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
#warning 友盟推送需要将tokenid 添加到友盟后台信息中
    //下面这个token是将获取的nsdata转换成String,应为指定推送时我们需要将这个传给服务端。
    NSString *tokenIdString =[NSString stringWithFormat:@"%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""]                 stringByReplacingOccurrencesOfString: @" " withString: @""]];
    NSLog(@"tokenidstring %@",tokenIdString);
    //1.2.7友盟版本开始不需要用户在手动注册devicetonken，SDK 会自动注册
    [UMessage registerDeviceToken:deviceToken];
}
//ios10 以下使用这个方法接收通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //关闭U-Push自带弹框
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
    self.userInfo = userInfo;
    //定制自己的弹出框
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        //程序正在运行时 弹出推送提示框
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:userInfo[@"content"]  delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}
//ios 10新增：处理前台收到的通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSDictionary *userinfoDic = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
    {
        /**应用处于前台是的原创推送接收 先关闭友盟自带的弹出框*/
        [UMessage setAutoAlert:NO];
        //必要语句
        [UMessage didReceiveRemoteNotification:userinfoDic];
    }else
    {
        //应用处于前台时的本地推送接受
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    if (@available(iOS 10.0, *)) {
        completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
    } else {
        // Fallback on earlier versions
    }
}
//ios 10新增：处理后台收到的通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    NSDictionary *userInfoDic = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
    {
        [UMessage didReceiveRemoteNotification:userInfoDic];
    }
    else
    {
        //应用处于后台是的本地推送接收
    }
    completionHandler();
}

/*#pragma mark - 极光推送
- (void)jPshNotificenterWithApplication:(UIApplication *)application lauchOptionsDic:(NSDictionary *)launchOptions
{
    //注册系统通知
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    if([UIDevice currentDevice].systemVersion.floatValue >= 10.0)
    {
        JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
        if (@available(iOS 10.0, *)) {
            entity.types = UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
        } else {
            // Fallback on earlier versions
        }
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    }
    else if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0)
    {
        //可添加自定义的cztegories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    //根据key注册
    [JPUSHService setupWithOption:launchOptions appKey:JPUSHKEY channel:@"App Store" apsForProduction:NO advertisingIdentifier:nil];
    //接收应用内消息
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    //极光推送登录成功后可以 注册别名
    //    [defaultCenter addObserver:self selector:@selector(registerAlias:) name:kJPFNetworkDidLoginNotification object:nil];
}
//注册deviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [JPUSHService registerDeviceToken:deviceToken];
}
#pragma mark - JPUSHRegisterDelegate
//ios 10 support ，前台收到通知，后台不会执行这个方法
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler
{
    NSDictionary *userInfoDic = (NSDictionary *)notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
        {
            [JPUSHService handleRemoteNotification:userInfoDic];
        }
    } else {
        // Fallback on earlier versions
    }
    //需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    completionHandler(UIUserNotificationTypeAlert);
    NSLog(@"通知内容 %@",notification.request.content.body);
    
}
// iOS 10 Support，用户点击了通知进入app
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    NSDictionary *userInfoDic = (NSDictionary *)response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
    {
        [JPUSHService handleRemoteNotification:userInfoDic];
    }
    completionHandler();
}
#pragma mark 解析极光推送的应用内消息
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"解析极光推送的应用内消息：%@",userInfo);
    UIAlertView *aertView = [[UIAlertView alloc] initWithTitle:@"极光推送" message:userInfo[@"content"] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [aertView show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
//获取 deviceToken 失败后 远程推送（极光推送）打开失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"获取 device token 失败 %@", error);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}*/


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
