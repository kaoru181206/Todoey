//
//  Item.swift
//  Todoey
//
//  Created by 白髪馨 on 2022/10/03.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted dynamic var title: String = ""
    @Persisted dynamic var done: Bool = false
    @Persisted dynamic var dateCreated: Date?
    
    @Persisted(originProperty: "items") var parentCategory: LinkingObjects<Category>
}
