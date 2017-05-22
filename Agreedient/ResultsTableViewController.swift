//
//  ResultsTableViewController.swift
//  Agreedient
//
//  Created by Ethan Lillie on 5/19/17.
//  Copyright © 2017 ME. All rights reserved.
//

import UIKit
import RealmSwift

class ResultsTableViewController: UITableViewController {

    let realm = try! Realm()
    
    var ingredient:Ingredient? = nil
    
    var recipes: [Recipe]? {
        return ingredient != nil ? Array(realm.objects(Recipe.self)).filter { $0.ingredients.contains(ingredient!) } : nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recipes == nil {
            return 0
        }
        
        return recipes!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeTableViewCell

        let recipe = recipes![indexPath.row]
        
        cell.titleLabel.text = recipe.title
        cell.ingredientsLabel.text = Array(recipe.ingredients).map{ $0.name }.joined(separator: ", ")
        
        if let thumbnail = recipe.imgData  {
            cell.thumbnail.image = UIImage(data: thumbnail as Data)
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
}
