//
//  DrinkTableViewCell.swift
//  CocktailsLover
//
//  Created by Artem Musel on 15.09.2020.
//  Copyright © 2020 Artem Musel. All rights reserved.
//

import UIKit

class DrinkTableViewCell: UITableViewCell {

  @IBOutlet weak var drinkImageView: UIImageView!
  @IBOutlet weak var drinkNameLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  var imageUrl = String()
}
