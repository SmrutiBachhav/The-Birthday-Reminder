//
//  Category.swift
//  The Birthday Reminder
//
//  Created by Smruti Bachhav on 04/09/25.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    
    //forward relation
    let items = List<Item>() //contains list of item object
}
