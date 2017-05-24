//
//  RecipeTableViewCell.swift
//  Agreedient
//
//  Created by Ethan Lillie on 2017-05-20.
//  Copyright © 2017 Decorator Technologies, Inc. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    
  @IBOutlet
  private var thumbnail: UIImageView!

  @IBOutlet
  private var titleLabel: UILabel!

  @IBOutlet
  private var ingredientsLabel: UILabel!

  var recipe: Recipe? = nil {
    didSet {
      guard let recipe = recipe else {
        titleLabel.text = nil
        ingredientsLabel.text = nil
        // TODO: Use a placeholder image
        thumbnail.image = nil
        return
      }
      titleLabel.text = recipe.title
      ingredientsLabel.text = recipe.ingredients
        .map{ $0.name }
        .joined(separator: ", ")
      guard
        let url = URL(string: recipe.thumbnail),
        let data = try? Data(contentsOf: url)
        else {
          // TODO: Use a default image
          return
      }
      thumbnail.image = UIImage(data: data)
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    recipe = nil
  }
    
}
