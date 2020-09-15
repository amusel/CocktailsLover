//
//  Drink.swift
//  CocktailsLover
//
//  Created by Artem Musel on 15.09.2020.
//  Copyright © 2020 Artem Musel. All rights reserved.
//

import Foundation

struct Drink: Codable {
  let name: String
  let imageString: String
  
  enum CodingKeys: String, CodingKey {
    case name = "strDrink"
    case imageString = "strDrinkThumb"
  }
}

//helper for decoding
struct Drinks: Codable {
  let drinks: [Drink]
}
