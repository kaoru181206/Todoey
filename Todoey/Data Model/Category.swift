//
//  Category.swift
//  Todoey
//
//  Created by 白髪馨 on 2022/10/03.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted dynamic var name: String = ""
    
    @Persisted var items = List<Item>()
}
