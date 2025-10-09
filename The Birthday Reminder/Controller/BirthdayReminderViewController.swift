//
//  ViewController.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 29/07/25.
//

import UIKit
import RealmSwift
import UserNotifications
import ChameleonFramework

class BirthdayReminderViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
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
        tableView.separatorStyle = .none
        tableView.reloadData()
        NotificationManager.shared.requestNotificationPermission()
    }
    
    //just before viewDidLoad,nav stack is established, any controller is not nil
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            //selectedcategry can forced unwrap as we have done optional binding earlier ?.color
            title = selectedCategory?.name
            //check if navcontroller is nil then....
            guard let navBar = navigationController?.navigationBar else {fatalError("Nav controller doesn't exist! it is nil")
            }
            if let navBarColor = UIColor(hexString: colorHex) {
                navBar.backgroundColor = navBarColor
                //applies to nav items and bar button items
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                
                searchBar.barTintColor = navBarColor
            }
        }
    }
    

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
            //darken(byper...) is optional and backgroundColor needs definite value therfore if let to unwrap the optional
            //check for UIColor is not empty then darken by.... SelectedCategory will definitely have value as todoItems definitely has value and comes from selectedCategory(loadItems)
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count)) {
                configurePebbleView(for: cell, with: color)
                
                //cell.backgroundColor = color
                //text color according to background color (light->black text or dark->white text)
                //cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true
            }
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
                destinationVC.category = selectedCategory  // Pass the selected category
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


