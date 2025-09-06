//
//  ViewController.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 29/07/25.
//

import UIKit
import RealmSwift

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        /*for USING USER DEFAULT FOR  LOCAL DATA PERSISTANCE
         let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
         */
        
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


