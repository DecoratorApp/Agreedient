//
//  RecipeTableViewCell.swift
//  Agreedient
//
//  Created by Ethan Lillie on 5/20/17.
//  Copyright © 2017 ME. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ingredientsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
