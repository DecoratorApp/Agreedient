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
    dynamic var title = ""
    dynamic var link = ""
    let ingredients = List<Ingredient>()
    dynamic var imgData:NSData? = nil
    
    override static func primaryKey() -> String? {
        return "link" // url should be unique to the recipe, while title ("Chocolate delights", for instance) might not.
    }
    
//    override static func indexedProperties() -> [String] {
//        return ["title"]
//    }
    
    
//    func someFunc() {
//        ingredients.append(Ingredient(value: "name = 'my dad'"))
//        
//        print(ingredients)
//    }
    
}
