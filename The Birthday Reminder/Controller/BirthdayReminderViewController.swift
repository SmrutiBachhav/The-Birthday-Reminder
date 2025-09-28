//
//  ViewController.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 29/07/25.
//

import UIKit
import RealmSwift
import UserNotifications

class BirthdayReminderViewController: SwipeTableViewController {
    var realm = try! Realm()
    var items : Results<Item>!
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    var selectedItem: Item?
    //let defualts = UserDefaults.standard
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var daysRemaining: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        NotificationManager.shared.requestNotificationPermission()

        //request notification permissions if needed
        //requestNotificationPermissionIfNeeded()
        
        /*for USING USER DEFAULT FOR  LOCAL DATA PERSISTANCE
         let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
         */
        
    }
    
//    //MARK: - Notification permission
//    func requestNotificationPermissionIfNeeded() {
//        NotificationManager.shared.checkNotificationPermission { (granted) in
//            if !granted {
//                self.showNotificationPermissionAlert()
//            }
//        }
//    }
//    
//    func showNotificationPermissionAlert() {
//        let alert = UIAlertController(
//            title: "Birthday Notifications",
//            message: "We need permission to send you notifications about your birthdays.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
//            NotificationManager.shared.requestNotificationPermission { granted in
//                if granted {
//                    print("Notification allowed!")
//                } else {
//                    print("User declined notification permission")
//                }
//            }
//        }))
//        present(alert, animated: true)
//    }
//
//    //reschedule notificatiosn for current category
//    func resceduleNotificationForCurrentCategory() {
//        guard let category = selectedCategory else { return }
//        //NotificationManager.shared.checkNotificationPermission { granted in
//            //guard granted else { return }
//            NotificationManager.shared.rescheduleNotificationsForCategory(withID: category._id)
//        //}
//    }
    //MARK: - TableView DataSource Method
    
    //to get number of Rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    //specifies how a cell is to be showned
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //reusable cell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.name
        } else {
            cell.textLabel?.text = "No Birthdays Added"
        }
        
    //        cell.accessoryView = item.wished ? UIImageView(image: UIImage(systemName:"gift.fill")) : .none
        //        (cell.accessoryView as? UIImageView)?.tintColor = .systemPink
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //itemArray[indexPath.row].wished = !itemArray[indexPath.row].wished
        //saveItems()
        performSegue(withIdentifier: "showDetails", sender: self)
        //performSegue(withIdentifier: "addItem", sender: self)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItem" {
            if let destinationVC = segue.destination as? AddViewController {
                destinationVC.category = selectedCategory
                destinationVC.delegate = self
                //destinationVC.itemToShow = selectedItem
            }
        }
        if segue.identifier == "showDetails" {
            if let destinationVC = segue.destination as? ShowViewController,
               let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.itemToShow = items?[indexPath.row]
            }
        }
    }
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        selectedItem = nil
        performSegue(withIdentifier: "addItem", sender: self)
    }
       
    //MARK: - Data Manipulation
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
    
    //delete data
    override func updateModel(at indexPath: IndexPath) {
        if let bdyDeletion = items?[indexPath.row] {
            //cancel notification before deleting
            //NotificationManager.shared.cancelNotification(for: bdyDeletion)
            
            // Recreate the identifier based on name + date (same as in scheduleReminder)
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day, .month], from: bdyDeletion.date)
                let identifier = "birthday-\(bdyDeletion.name)-\(components.month ?? 0)-\(components.day ?? 0)"
                
                // Cancel notification
                NotificationManager.shared.cancelReminder(identifier: identifier)
            do {
                try realm.write {
                    realm.delete(bdyDeletion)
                }
                
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
}

//MARK: - Delegate implementation for data update after navigation
extension BirthdayReminderViewController: AddViewControllerDelegate {
    func didUpdateItemInBdyList(_ item: Item) {
        tableView.reloadData()
    }
    
    func didUpdateBirthday(_ item: Item) {
        loadItems()
        tableView.reloadData()
    }
}

    
//MARK: - Seach BAr methods
extension BirthdayReminderViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("name contains[cd] %@", searchBar.text!).sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


