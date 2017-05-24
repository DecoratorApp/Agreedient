//
//  Recipe.swift
//  Agreedient
//
//  Created by Ethan Lillie on 5/19/17.
//  Copyright © 2017 ME. All rights reserved.
//

import Foundation
import RealmSwift

class Recipe: Object {

  override static func primaryKey() -> String? {
    // href should be unique to the recipe, while title ("Chocolate delights", for instance) might not.
    return "href"
  }

  dynamic var href = ""
  dynamic var title = ""
  dynamic var thumbnail = ""
  let ingredients = List<Ingredient>()

  convenience init(href: String,
                   title: String,
                   thumbnail: String,
                   ingredients: [Ingredient]) {
    self.init()
    self.href = href
    self.title = title
    self.thumbnail = thumbnail
    self.ingredients.append(objectsIn: ingredients)
  }

}
