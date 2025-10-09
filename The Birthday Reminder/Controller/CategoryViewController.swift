//
//  CategoryViewController.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 24/08/25.
//

import UIKit
import RealmSwift
import ChameleonFramework

//import UserNotifications
class CategoryViewController: SwipeTableViewController {
    
    //var categories = [Category]()
    var categories : Results<Category>?
    
    let baseColor = UIColor(hexString: "#5A1B43")
    
    let realm = try! Realm()
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.separatorStyle = .none
//        if let baseColor = baseColor {
//            view.backgroundColor = UIColor(
//                gradientStyle: .topToBottom,
//                withFrame: view.bounds,
//                andColors: [
//                    baseColor.lighten(byPercentage: 0.25) ?? baseColor,
//                    baseColor.darken(byPercentage: 0.75) ?? baseColor
//                ]
//            )
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation Bar doesn't exist it is null") }
        navBar.backgroundColor = UIColor(hexString: "#5A1B43")
        navBar.tintColor = ContrastColorOf(navBar.backgroundColor!, returnFlat: true)
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBar.backgroundColor!, returnFlat: true)]
    }
    
    //MARK: - TableView DataSource Methods
    
    //get number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    //specifies how a cell to be showned
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
            
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added!"
        
        if let category = categories?[indexPath.row] {
            guard let categoryColor = UIColor(hexString: category.color) else {
                fatalError()
            }
            configurePebbleView(for: cell, with: categoryColor)
//            cell.backgroundColor = categoryColor
           cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        
        //cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems",
           let destinationVC = segue.destination as? BirthdayReminderViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

    
    //MARK: - Add new categories
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
                let newCategory = Category()
                newCategory.name = texteField.text!
                newCategory.color = UIColor.randomFlat().hexValue()
                self.save(category: newCategory)
                //self.categoryArray.append(newCategory) no need to append as Results is auto-updating container type
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
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Enter saving category: \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        self.tableView.reloadData()
    }
    
    //delete data
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryForDeletion)
                }
                
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
    
}

    

