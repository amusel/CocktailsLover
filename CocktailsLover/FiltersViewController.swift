//
//  FiltersViewController.swift
//  CocktailsLover
//
//  Created by Artem Musel on 15.09.2020.
//  Copyright © 2020 Artem Musel. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var applyButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  private let reuseIdentifier = "CocktailCategoryCell"
  
  /*There are many other ways to persist selectedCategoriesNames:
  delegates, notifications, singletons...
  I just decided that completionHandler is more convenient.
  But usually I use delegate*/
  var completion: (([Int])->Void)?
  
  var cocktailResults = [DrinksCategory]()
  var selectedCategoriesIndeces = [Int]()
  
  //MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
    label.text = "Filters"
    navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    
    navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "arrowBack"), style: .done, target: self, action: #selector(backPressed)), UIBarButtonItem.init(customView: label)]
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    //to enable content scroll about applyButton
    tableView.contentInset.bottom = UIScreen.main.bounds.size.height - applyButton.frame.minY
  }
  
  //MARK: Actions
  @IBAction func applyPressed(_ sender: Any) {
    completion?(selectedCategoriesIndeces.sorted())
  
    navigationController?.popViewController(animated: true)
  }
  
  @objc func backPressed(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
  
  //MARK: TableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard cocktailResults.count > 0 else {
      return 1
    }
    
    return cocktailResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard cocktailResults.count > 0 else {
      let cell = UITableViewCell()
      cell.textLabel?.text = "Oops, something went wrong!\nTry to check your internet connection🥺"
      cell.textLabel?.textAlignment = .center
      
      return cell
    }
    
    let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    cell.textLabel?.text = cocktailResults[indexPath.row].name
    cell.accessoryType = selectedCategoriesIndeces.contains(indexPath.row) ? .checkmark : .none
    
    return cell
  }
  
  //MARK: TableViewDelegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if selectedCategoriesIndeces.contains(indexPath.row) {
      selectedCategoriesIndeces.removeAll { $0 == indexPath.row }
    } else {
      selectedCategoriesIndeces.append(indexPath.row)
    }
    
    tableView.cellForRow(at: indexPath)?.accessoryType = selectedCategoriesIndeces.contains(indexPath.row) ? .checkmark : .none
  }
}

