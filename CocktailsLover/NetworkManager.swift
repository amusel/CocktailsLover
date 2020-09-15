//
//  NetworkManager.swift
//  CocktailsLover
//
//  Created by Artem Musel on 15.09.2020.
//  Copyright © 2020 Artem Musel. All rights reserved.
//

import UIKit

class NetworkManager {
  
  static let shared = NetworkManager()
  private init() { }
  
  let imageCache = NSCache<NSString, UIImage>()
  
  private let baseURL = "https://www.thecocktaildb.com/api/json/v1/1/"
  
  func requestForCategories(completion: @escaping ([DrinksCategory]?)->Void) {
    let request = URLRequest(url: URL(string: "\(baseURL)list.php?c=list")!)
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      guard error == nil, let data = data else {
        completion(nil)
        return
      }
      
      let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: [Any]]
      
      guard let json = jsonData else {
        completion(nil)
        return
      }
      
      var cocktailResults = [DrinksCategory]()
      json?["drinks"]?.forEach {
        if let dict = $0 as? NSDictionary, let id = dict.value(forKey: "strCategory") as? String {
          cocktailResults.append(DrinksCategory(name: id))
        }
      }
      
      completion(cocktailResults)
    }.resume()
  }
  
  func requestForDrinksIn(category: String, completion: @escaping ([Drink]?)->Void) {
    let request = URLRequest(url: URL(string: "\(baseURL)filter.php?c=\(category.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!)")!)
    let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
      guard error == nil, let data = data else {
        completion(nil)
        return
      }
      
      var drinks: [Drink]
      let decoder = JSONDecoder()
      do {
        drinks = (try decoder.decode(Drinks.self, from: data)).drinks
      } catch {
        return
      }
      
      completion(drinks)
    }
    
    //to posibly download list before images of previous category
    dataTask.priority = URLSessionTask.highPriority
    dataTask.resume()
  }
  
  func requestForDrinkImage(withUrl url: String, completion: @escaping (UIImage?, String)->Void) {
    if let cachedImage = imageCache.object(forKey: url as NSString) {
      completion(cachedImage, url)
    }
    
    URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
      guard let data = data, error == nil else { return }
      
      if let image = UIImage(data: data) {
        self.imageCache.setObject(image, forKey: url as NSString)
        completion(image, url)
      }

    } .resume()
  }
}
