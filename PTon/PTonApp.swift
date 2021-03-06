//
//  PTONApp.swift
//  PTON
//
//  Created by 이경민 on 2021/10/12.
//

import SwiftUI
import Firebase
import KakaoSDKAuth
import KakaoSDKCommon
import FirebaseMessaging
import Photos
//import NaverThirdPartyLogin


@main
struct PTONApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init(){
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
            
//            LoginPageView()
//                .withErrorHandling()
        }
    }
}

final class AppDelegate:UIResponder,UIApplicationDelegate{
    typealias LaunchOptionsKey = UIApplication.LaunchOptionsKey
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        KakaoSDK.initSDK(appKey: "3ab88a82d4b9a11f1a993c02250270ce")
        
        FirebaseMessaging.Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions:UNAuthorizationOptions = [.badge,.sound,.alert]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_,_ in})
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FirebaseMessaging.Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate:UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner,.sound,.badge,.list])
    }
}

extension AppDelegate:MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else{return}
        
        let dataDict:[String:String] = ["token":token]
        NotificationCenter.default.post(name: NSNotification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}
