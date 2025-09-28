//
//  AppDelegate.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 29/07/25.
//

import UIKit
import RealmSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //happens as the first thing when the app loads even before the viewDidLoad() method
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //set up notification center delegate
        UNUserNotificationCenter.current().delegate = self
        
        //request notification permissions
        NotificationManager.shared.requestNotificationPermission() 
        
        print(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "No Realm file URL")
//        
//        do {
//            _ = try Realm()
//        } catch {
//            print("Error initializing Realm: \(error)")
//        }
//        
        return true
    }
    
    
    
//    // MARK: UISceneSession Lifecycle
//    // Handle app entering background
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        // Reschedule all notifications when app goes to background
//        NotificationManager.shared.scheduleNotificationsForAllItems()
//    }
//    
//    // Handle app becoming active
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationManager.shared.checkNotificationPermission { granted in
            DispatchQueue.main.async {
                print("🔔 Notifications permission updated: \(granted)")
                if granted {
                    NotificationManager.shared.rescheduleAllReminders()
                }
            }
        }
    }
//    func sceneDidBecomeActive(_ scene: UIScene) {
//        NotificationManager.shared.checkNotificationPermission { granted in
//            DispatchQueue.main.async {
//                print("🔔 Notifications permission updated: \(granted)")
//                if granted {
//                    NotificationManager.shared.rescheduleAllBirthdays()
//                }
            //}
        //}
   // }

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//    }
//
//    }
//
//// MARK: - UNUserNotificationCenterDelegate
//extension AppDelegate: UNUserNotificationCenterDelegate {
//    
//    // Handle notification when app is in foreground
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        
//        // Show notification even when app is in foreground
//        completionHandler([.banner, .badge, .sound])
//    }
//    
//    // Handle notification tap
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        
//        let identifier = response.notification.request.identifier
//        print("Notification tapped: \(identifier)")
//        
//        // You can parse the identifier to get item info and navigate to specific birthday
//        // For example, if identifier is "birthday_John_1234567890"
//        if identifier.hasPrefix("birthday_") {
//            // Extract name and navigate to that person's details
//            handleBirthdayNotificationTap(identifier: identifier)
//        }
//        
//        completionHandler()
//    }
//    
//    // Handle birthday notification tap - navigate to specific birthday
//    func handleBirthdayNotificationTap(identifier: String) {
//        // Parse identifier to extract name and timestamp
//        let components = identifier.components(separatedBy: "_")
//        guard components.count >= 3,
//              let timestampString = components.last,
//              let timestamp = Double(timestampString) else {
//            print("Could not parse notification identifier: \(identifier)")
//            return
//        }
//        
//        let name = components[1]
//        let birthdayDate = Date(timeIntervalSince1970: timestamp)
//        
//        // Find the item in Realm
//        DispatchQueue.main.async {
//            self.navigateToBirthdayItem(name: name, date: birthdayDate)
//        }
//    }
//    
//    func navigateToBirthdayItem(name: String, date: Date) {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let window = windowScene.windows.first,
//              let rootViewController = window.rootViewController else {
//            return
//        }
//        
//        // Navigate to the specific birthday item
//        // This depends on your navigation structure
//        if let navController = rootViewController as? UINavigationController {
//            // Pop to root if needed
//            navController.popToRootViewController(animated: false)
//            
//            // You might want to implement a method to find and show the specific item
//            // For now, we'll just show an alert with the birthday info
//            let alert = UIAlertController(
//                title: "Birthday Reminder",
//                message: "It's \(name)'s birthday today!",
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            
//            if let topVC = navController.topViewController {
//                topVC.present(alert, animated: true)
//            }
//        }
 }



extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound]) // show alert even in foreground
    }
    
    
}
