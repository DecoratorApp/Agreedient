//
//  ViewController.swift
//  Agreedient
//
//  Created by Ethan Lillie on 5/19/17.
//  Copyright © 2017 ME. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet var navBar: UINavigationBar!
    
    let refreshControl = UIRefreshControl()
    var tableViewController: ResultsTableViewController?
    
    let realm = try! Realm()
    
    let ingredients = ["egg", "apple", "flour", "chocolate"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.\
        
        refreshControl.addTarget(self, action: #selector(refreshControlDidRefresh), for: .valueChanged)
        
        tableViewController?.refreshControl = refreshControl
    }
    
    func refreshControlDidRefresh() {
        let ingredientName = getRandomIngredient()
        
        let ingredient = realm.object(ofType: Ingredient.self, forPrimaryKey: ingredientName) ?? Ingredient(value: [ingredientName])
        
        tableViewController?.ingredient = ingredient
        
        if let preloadedRecipes = tableViewController!.recipes {
            navBar.topItem?.title = "\(preloadedRecipes.count) " + ingredientName.capitalized + " Recipes"
        }
        
        tableViewController?.tableView.reloadData()
        
        try! self.realm.write {
            self.realm.add(ingredient, update: true)
        }
        
        // Asynchronous
        Alamofire.request("http://www.recipepuppy.com/api/?i=\(ingredientName)").responseJSON { response in
            // parse JSON, download and process images
            
//            usleep(1000000) //delay added so that we can see that our pre-downloaded entries are working. 
            
            let dictionary = response.result.value as! NSDictionary
            
            let resultsArray = dictionary["results"] as! NSArray

            var thumbnailLinkFromRecipeLink = [String:String]()
            
            var recipes = [Recipe]()
            
            for result in resultsArray {
                let recipeDictionary = result as! NSDictionary
                
                let title: String = recipeDictionary["title"] as! String
                let link: String = recipeDictionary["href"] as! String
                let ingredientsString: String = recipeDictionary["ingredients"] as! String
                let ingredients: [Ingredient] = ingredientsString.characters.split(separator: ",").map(String.init).map { Ingredient(value: ["name": $0.trimmingCharacters(in: .whitespacesAndNewlines)]) }
                let thumbnailLink: String = recipeDictionary["thumbnail"] as! String
                
                thumbnailLinkFromRecipeLink[link] = thumbnailLink
                
                recipes.append(Recipe(value: ["title": title.trimmingCharacters(in: .whitespacesAndNewlines), "link": link.trimmingCharacters(in: .whitespacesAndNewlines), "ingredients": ingredients]))
            }
            
            self.downloadThumbnails(for: recipes, and: thumbnailLinkFromRecipeLink)
            
            try! self.realm.write {
                for recipe in recipes {
                    
                    self.realm.add(recipe, update: true)
                }
            }
            
            self.navBar.topItem?.title = "\(self.tableViewController!.recipes!.count) " + ingredientName.capitalized + " Recipes"
            
            self.tableViewController?.tableView.reloadData()
            
            self.refreshControl.endRefreshing()
        }
    }
    
    func downloadThumbnails(for recipes: [Recipe], and thumbnailLinkFromRecipeLink: [String:String]) {
        var thumbnailDataFromRecipeLink = [String: Data]()
        
        var recipesAwaitingDownload = Set(recipes.map { $0.link })
        
        for recipe in recipes {
            if recipe.imgData == nil {
                Alamofire.request(thumbnailLinkFromRecipeLink[recipe.link]!,
                                  method: .get,
                                  parameters: nil,
                                  encoding: URLEncoding.default,
                                  headers: nil).response { response in
                                    thumbnailDataFromRecipeLink[recipe.link] = response.data
                                    
                                    recipesAwaitingDownload.remove(recipe.link)
                                    
                                    if recipesAwaitingDownload.isEmpty {
                                        try! self.realm.write {
                                            for recipe in recipes {
                                                
                                                if let thumbnailData = thumbnailDataFromRecipeLink[recipe.link] {
                                                    recipe.imgData = thumbnailData as NSData
                                                }
                                            }
                                        }
                                        self.tableViewController?.tableView.reloadData()
                                    }
                }
            }
        }
    }
    
    func getRandomIngredient() -> String {
        return ingredients[Int(arc4random_uniform(4))]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TableViewControllerEmbedSegue" {
            tableViewController = segue.destination as? ResultsTableViewController
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

