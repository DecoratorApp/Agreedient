//
//  ViewController.swift
//  Agreedient
//
//  Created by Ethan Lillie on 5/19/17.
//  Copyright © 2017 ME. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet var navBar: UINavigationBar!
    let refreshControl = UIRefreshControl()
    
    let ingredients = ["egg", "apple", "flour", "chocolate"]
    
    var tableViewController: UITableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.\
        
        refreshControl.addTarget(self, action: #selector(refreshControlDidRefresh), for: .valueChanged)
        
        tableViewController?.refreshControl = refreshControl
    }
    
    func refreshControlDidRefresh() {
        print(getRandomIngredient())
    
        Alamofire.request("http://www.recipepuppy.com/api/?i=\(getRandomIngredient())").responseJSON { response in
            print(response.response)
            print(response.result.value)
            
            self.refreshControl.endRefreshing()
        }
    }
    
    func getRandomIngredient() -> String {
        return ingredients[Int(arc4random_uniform(4))]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TableViewControllerEmbedSegue" {
            tableViewController = segue.destination as? UITableViewController
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

