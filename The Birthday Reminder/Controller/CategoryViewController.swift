//
//  CategoryViewController.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 24/08/25.
//

import UIKit
import CoreData
import UserNotifications
class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let alert = UIAlertController(title: "Grant Permission", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
                if success {
                    print("Permission granted")
                } else if let error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
      ))
        present(alert, animated: true, completion: nil)

        loadCategories()
        
    }
    
    //MARK: - TableView DataSource Methods
    
    //get number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    //specifies how a cell to be showned
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
            
        cell.textLabel?.text = categories[indexPath.row].name
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! BirthdayReminderViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }

    
    //MARK: - Add new items
    @IBAction func addButtonPressd(_ sender: UIBarButtonItem) {
        var texteField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            if texteField.text == "" {
                let alert = UIAlertController(title: "Error", message: "You must enter a category name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let newCategory = Category(context: self.context)
                newCategory.name = texteField.text!
                self.categories.append(newCategory)
                
                self.saveCategories()
                
                print("Added category")
                
            }
        }
        
        alert.addTextField { (field) in
            field.placeholder = "Add a new category"
            texteField = field
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Method
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
}

    
