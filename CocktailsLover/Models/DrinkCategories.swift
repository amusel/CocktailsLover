//
//  DrinkCategories.swift
//  CocktailsLover
//
//  Created by Artem Musel on 15.09.2020.
//  Copyright © 2020 Artem Musel. All rights reserved.
//

import Foundation

struct DrinksCategory {
  var name = ""
  var drinks = [Drink]()
  
  init(name: String) {
    self.name = name
  }
}
