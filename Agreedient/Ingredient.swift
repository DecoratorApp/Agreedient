//
//  Ingredient.swift
//  Agreedient
//
//  Created by Ethan Lillie on 2017-05-20.
//  Copyright © 2017 Decorator Technologies, Inc. All rights reserved.
//

import RealmSwift

class Ingredient: Object {

  override static func primaryKey() -> String {
    return "name"
  }

  override static func indexedProperties() -> [String] {
    return ["name"]
  }

  dynamic var name: String = ""
  let recipes = LinkingObjects(fromType: Recipe.self, property: "ingredients")

  convenience init(name: String) {
    self.init()
    self.name = name
  }

}
