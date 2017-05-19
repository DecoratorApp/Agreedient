//
//  ViewController.swift
//  Agreedient
//
//  Created by Ethan Lillie on 5/19/17.
//  Copyright © 2017 ME. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet var navBar: UINavigationBar!
    let refreshControl = UIRefreshControl()
    
    var tableViewController: UITableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableViewController?.refreshControl = refreshControl
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

