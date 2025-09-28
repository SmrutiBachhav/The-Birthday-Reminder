//
//  ReminderView.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 23/09/25.
//

import UIKit
import UserNotifications
import RealmSwift

class NotificationManager {
    static let shared  = NotificationManager()
    private init() {}
    var isPermissionGranted: Bool = false
    //request permission once
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission! \(error)")
            } else if granted {
                print("Notification permission granted!")
            } else {
                print("Notification permission not granted!")
            }
        }
    }
    
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let granted = (settings.authorizationStatus == .authorized)
            self.isPermissionGranted = granted
            completion(granted)
//            if settings.authorizationStatus == .authorized {
//                completion(true)
//            } else {
//                completion(false)
//            }
        }
    }
    
    func requestNotificationPermissionIfNeeded(for name: String, on date: Date, doRepeat repeatYearly: Bool, from viewController: UIViewController) {
        checkNotificationPermission { (granted) in
            DispatchQueue.main.async {
                if granted {
                    self.scheduleReminder(for: name, on: date, doRepeat: repeatYearly)
                } else {
                    self.showNotificationPermissionAlert(on: viewController)
                }
            }
        }
    }
    
    func showNotificationPermissionAlert(on viewController: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Notification Disbled",
                message: "To get birthday reminders, please enable notifications in Settings.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { _ in
                if let appSettings = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
//                    UNUserNotificationCenter.current().getNotificationSettings { settings in
//                        if settings.authorizationStatus != .authorized {
//                            self.requestNotificationPermission()
//                        }
//                    }
                }
            }))
            
            viewController.present(alert, animated: true)
            
        }
    }
    
    
    func scheduleReminder(for name: String, on date: Date, doRepeat repeatYearly: Bool) {
        //creat notification content
        let content = UNMutableNotificationContent()
        content.title = "It's \(name)'s Birthday!"
        content.subtitle = "Wish them a very Happy Birthday!"
        content.body = "Don't forget to give them your planned surprise!"
        content.sound = UNNotificationSound.default
        
        //notification trigger time(eg. after 10 seconds)
        //extract date components (only day & month for yearly repetition)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeatYearly)
        let identifier = "birthday-\(name)-\(components.month ?? 0)-\(components.day ?? 0)"
        //notifications can be tied to Realm IDs (better than names).
        //let identifier = id ?? "birthday-\(UUID().uuidString)"
        //create notification request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        //send notification to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification! \(error)")
            } else {
                print("Notification sent successfully!")
            }
        }
    }
   
    //reschedule notification after updating settings
    func rescheduleAllReminders() {
        guard isPermissionGranted else {
            print("Cannot reschedule, notifications not allowed")
            return
        }
        
        let realm = try! Realm()
        let birthdays = realm.objects(Item.self)
        
        for birthday in birthdays {
            // Schedule each birthday
            scheduleReminder(for: birthday.name, on: birthday.date, doRepeat: birthday.repeatYearly)
        }
        
        print("All reminders rescheduled!")
    }
    
    //cancel a birthday reminder if needed
    func cancelReminder(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Reminder deleted as well!")
    }
    
    

}
