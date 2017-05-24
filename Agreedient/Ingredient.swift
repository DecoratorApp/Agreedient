//
//  Ingredient.swift
//  Agreedient
//
//  Created by Ethan Lillie on 5/20/17.
//  Copyright © 2017 ME. All rights reserved.
//

import Foundation
import RealmSwift

class Ingredient: Object {
    dynamic var name: String = ""
    
    let recipes = LinkingObjects(fromType: Recipe.self, property: "ingredients")
    
    override static func primaryKey() -> String {
        return "name"
    }
    
    override static func indexedProperties() -> [String] {
        return ["name"]
    }

  convenience init(name: String) {
    self.init()
    self.name = name
  }

}
