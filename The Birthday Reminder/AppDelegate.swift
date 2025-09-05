//
//  AppDelegate.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 29/07/25.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    //        // Override point for customization after application launch.
    //        //print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
    //        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
    //            if granted {
    //                print("🔓 Notification permission granted")
    //            }
    //        }
    //        return true
    //    }
    
    //happens as the first thing when the app loads even before the viewDidLoad() method
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        //        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        //            if granted {
        //                print("🔓 Notification permission granted")
        //                    }
        //        }
        
        print(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "No Realm file URL")
        
        do {
            _ = try Realm()
        } catch {
            print("Error initializing Realm: \(error)")
        }
        
        return true
    }
    
}
