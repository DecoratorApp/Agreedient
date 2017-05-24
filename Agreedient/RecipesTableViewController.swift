//
//  RecipesTableViewController.swift
//  Agreedient
//
//  Created by Brandon Zacharie on 2017-05-23.
//  Copyright © 2017 Decorator Technologies, Inc. All rights reserved.
//

import Alamofire
import PromiseKit
import RealmSwift
import SwiftyJSON
import UIKit

class RecipesTableViewController: UITableViewController {

  fileprivate let background = DispatchQueue(
    label: "com.decoratorapp.Agreedient.background",
    qos: .background,
    attributes: .concurrent,
    autoreleaseFrequency: .inherit,
    target: nil
  )
  fileprivate var realm: Realm?
  fileprivate var ingredients: Results<Ingredient>?
  fileprivate var ingredient = Ingredient()

  override func viewDidLoad() {
    super.viewDidLoad()
    do {
      try initializeRealm()
    }
    catch {
      // TODO: Show error
      return
    }
    ingredient = ingredients?.random(excluding: ingredient) ?? ingredient
    initializeTitle()
  }

  @IBAction
  func didChangeRefreshControl(_ sender: UIRefreshControl) {
    ingredient = ingredients?.random(excluding: ingredient) ?? ingredient
    initializeTitle()
    tableView.reloadData()
    Alamofire
      .request("http://www.recipepuppy.com/api/?i=\(ingredient.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")
      .validate()
      .responseJSON(queue: background)
      .then { [weak self] json throws -> Promise<Void> in
        let void: Promise<Void> = Promise(value: ())
        guard
          let strongSelf = self,
          let realm = strongSelf.realm,
          let results = json["results"].array
          else {
            return void
        }
        let recipes = results.flatMap { json -> Recipe? in
          guard
            let href = json["href"].url?.absoluteString,
            realm.object(ofType: Recipe.self, forPrimaryKey: href) == nil,
            let title = json["title"].string?
              .trimmingCharacters(in: .whitespacesAndNewlines),
            let thumbnail = json["thumbnail"].url?.absoluteString,
            let ingredients = json["ingredients"].string?
              .components(separatedBy: ",")
              .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
              .map({
                realm.object(ofType: Ingredient.self, forPrimaryKey: $0)
                  ?? Ingredient(name: $0)
              })
            else {
              return nil
          }
          return Recipe(
            href: href,
            title: title,
            thumbnail: thumbnail,
            ingredients: ingredients
          )
        }
        if recipes.isEmpty {
          return void
        }
        let oldCount = strongSelf.ingredient.recipes.count
        try realm.write {
          realm.add(recipes, update: true)
        }
        let newCount = strongSelf.ingredient.recipes.count
        if oldCount == newCount {
          return void
        }
        strongSelf.tableView.beginUpdates()
        strongSelf.tableView.insertRows(
          at: (oldCount ..< newCount).map { IndexPath(row: $0, section: 0) },
          with: .automatic
        )
        strongSelf.tableView.endUpdates()
        return void
      }
      .catch { error in
        debugPrint(error)
      }
      .always { [weak self] in
        self?.refreshControl?.endRefreshing()
        self?.initializeTitle()
      }
  }

  private func initializeRealm() throws {
    if realm == nil {
      realm = try Realm()
    }
    if ingredients == nil {
      ingredients = realm?.objects(Ingredient.self)
      try realm?.write {
        realm?.add(
          ["egg", "apple", "flour", "chocolate"]
            .filter { realm?.object(ofType: Ingredient.self, forPrimaryKey: $0) == nil }
            .map { Ingredient(name: $0) }
        )
      }
    }
  }

  private func initializeTitle() {
    navigationItem.title = ingredient.recipes.isEmpty
      ? "Pull to load recipes"
      : refreshControl?.isRefreshing == true
      ? "Fetching \(ingredient.name.capitalized) Recipes"
      : "\(ingredient.recipes.count) \(ingredient.name.capitalized) Recipes"
  }

}

// MARK: UITableViewDataSource

extension RecipesTableViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return ingredient.recipes.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell", for: indexPath)
    guard let recipeTableViewCell = cell as? RecipeTableViewCell else {
      return cell
    }
    recipeTableViewCell.recipe = ingredient.recipes[indexPath.row]
    return recipeTableViewCell
  }

  override func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70.0
  }

}

private extension Results {

  func random(excluding: T? = nil) -> T? {
    if isEmpty || count == 1 && excluding == first {
      return nil
    }
    var element: T
    repeat {
      element = self[Int(arc4random_uniform(UInt32(count)))]
    } while element == excluding
    return element
  }

}

private extension DataRequest {

  func responseJSON(queue: DispatchQueue? = nil,
                    options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<JSON> {
    return Promise { fulfill, reject in
      responseJSON(queue: queue, options: options) { response in
        switch response.result {
        case .success(let value):
          fulfill(JSON(value))
        case .failure(let error):
          reject(error)
        }
      }
    }
  }

}
