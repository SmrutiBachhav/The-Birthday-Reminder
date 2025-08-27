//
//  ViewController.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 29/07/25.
//

import UIKit
import CoreData

class BirthdayReminderViewController: UITableViewController {
    
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    let defualts = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*for USING USER DEFAULT FOR  LOCAL DATA PERSISTANCE
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
         */
      
    }
    //MARK: - TableView DataSource Method
    
    //to get number of Rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //specifies how a cell is to be showned
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "BdyReminderItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
            
        cell.textLabel?.text = item.name
        
        cell.accessoryView = item.wished ? UIImageView(image: UIImage(systemName:"gift.fill")) : .none
        (cell.accessoryView as? UIImageView)?.tintColor = .systemPink
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].wished = !itemArray[indexPath.row].wished
        
        saveItems()
        //tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var nameField = UITextField()
        var dateField = UITextField()
        let datePicker = UIDatePicker()
        var planField = UITextField()
        
        datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let alert = UIAlertController(title: "Add new Birthday Reminder", message: "", preferredStyle: .alert)
        
        //add text fields for name, date and plans
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            nameField = textField
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Date"
            dateField = textField
            dateField.inputView = datePicker //show date picker on tap
            
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Any plans?"
            planField = textField
        }
        
        //add ation
        let action = UIAlertAction(title: "Add Reminder", style: .default) { _ in
            guard let name = nameField.text, !name.isEmpty else {
                let alert = UIAlertController(title: "Error!", message: "Please enter a valid reminder", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            guard let dateText = dateField.text, !dateText.isEmpty else {
                let alert = UIAlertController(title: "Error!", message: "Please enter date", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            let selectedDate = datePicker.date
            self.showScheduleOptions(name: name, date: selectedDate, plan: planField.text ?? "")
            print("Added!")
            
            
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - For Date Picker
    @objc func dateChanged(_ sender: UIDatePicker) {
        if let alert = self.presentedViewController as? UIAlertController {
            if let dateField = alert.textFields?.first(where: { $0.placeholder == "Date" }) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                dateField.text = dateFormatter.string(from: sender.date)
            }
        }
    }
    
    //MARK: - Shows option for setting customized reminder(exact time, before one day or one week before)
    func showScheduleOptions(name: String, date: Date, plan: String) {
        let sheet  = UIAlertController(title: "Schedule Reminder", message: "Choose when you want to be notified", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "At exact Time", style: .default) { _ in            
            self.saveReminder(name: name, date: date, plan: plan, offset: 0)
        })
        
        sheet.addAction(UIAlertAction(title: "1 day before", style: .default) { _ in
            self.saveReminder(name: name, date: date, plan: plan, offset: -86400)
        })
        
        sheet.addAction(UIAlertAction(title: "1 week before", style: .default) { _ in
            self.saveReminder(name: name, date: date, plan: plan, offset: -604800)
        })
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(sheet, animated: true)
        
        print("Set!")
    }
    
    //MARK: - Saving each reminder
    func saveReminder(name: String, date: Date, plan: String, offset: TimeInterval) {
        let reminderDate = date.addingTimeInterval(offset)
        
        let newItem = Item(context: self.context)
        newItem.name = name
        newItem.date = date
        newItem.plan = plan
        newItem.remind = reminderDate
        newItem.parentCategory = selectedCategory
        
        self.itemArray.append(newItem)
        
        self.saveItems()
        scheduleNotification(name: name, date: date)
        print(reminderDate)
    }
    
    //MARK: - Schedule Notification(repeat Yearly or by default false)
    func scheduleNotification(name: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "🎂 Birthday Reminder"
        content.body = "Wish \(name) a Happy Birthday!"
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: date)

        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        // Repeat yearly on selected day and time
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Yearly birthday notification scheduled for \(name) on \(components.month!)/\(components.day!) at \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }
    
    
    
    
    
    /* USING USER DEFAULT FOR  LOCAL DATA PERSISTANCE
    //MARK: - Model Manipulation Method
    //encoding data into plist (property list) Items.plist to save it in json format
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding the item array! \(error)")
        }
        self.tableView.reloadData()
    }
    //decoding data from plist (property list) Items.plist
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding the item array! \(error)")
            }
        }
    }*/
    
    
    //MARK: - Model Manipulation Method using Core Data
    func saveItems() {
        do {
            //commit changes
            try context.save()
        } catch {
            print("Error svaing reminder: \(error)")
        }
        //reload data
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(),  predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - Seach BAr methods
extension BirthdayReminderViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        loadItems(with: request, predicate: predicate)
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
