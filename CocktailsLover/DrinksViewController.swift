//
//  DrinksViewController.swift
//  CocktailsLover
//
//  Created by Artem Musel on 15.09.2020.
//  Copyright © 2020 Artem Musel. All rights reserved.
//

import UIKit

class DrinksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  private let reuseIdentifier = "DrinkCell"
  
  private var drinkCategories = [DrinksCategory]()
  private var selectedCategoriesIndeces = [Int]()
  
  //MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureNavBar()
    
    tableView.dataSource = self
    tableView.delegate = self
    
    NetworkManager.shared.requestForCategories { categories in
      self.drinkCategories = categories ?? []
      self.selectedCategoriesIndeces = Array(0...self.drinkCategories.count-1)
      
      self.requestSectionDrinks(withIndex: 0)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "filtersSegue", let filtersVC = segue.destination as? FiltersViewController {
      
      filtersVC.cocktailResults = drinkCategories
      filtersVC.selectedCategoriesIndeces = selectedCategoriesIndeces
      
      filtersVC.completion = { selectedCategoriesIndeces in
        self.selectedCategoriesIndeces = selectedCategoriesIndeces
        self.tableView.reloadData()
        if let index = selectedCategoriesIndeces.first {
          self.requestSectionDrinks(withIndex: index)
        }
      }
    }
  }
  
  //MARK:Private methods
  private func configureNavBar() {
    navigationController?.navigationBar.tintColor = .black
    navigationController?.navigationBar.barTintColor = .white
    navigationController?.navigationBar.layer.masksToBounds = false
    navigationController?.navigationBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
    navigationController?.navigationBar.layer.shadowOpacity = 1
    navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    navigationController?.navigationBar.layer.shadowRadius = 4
    navigationController?.navigationBar.shadowImage = UIImage()
    
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
    label.text = "Drinks"
    self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
  }
  
  private func requestSectionDrinks(withIndex index: Int) {
    /* Pagination can be different. I call this function to load next section
     only when user has scrolled to the last row of current section. That is why you may
     have to wait till it loads. In real life application I would call pagination earlier.*/
    guard drinkCategories[index].drinks.count == 0 else {
      return
    }
    
    NetworkManager.shared.requestForDrinksIn(category: drinkCategories[index].name) { drinks in
      self.drinkCategories[index].drinks = drinks ?? []
      
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }
  
  //MARK: TableViewDataSource
  func numberOfSections(in tableView: UITableView) -> Int {
    return selectedCategoriesIndeces.count == 0 ? 1 : selectedCategoriesIndeces.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if selectedCategoriesIndeces.count == 0 {
      return 1
    }
    
    return drinkCategories[selectedCategoriesIndeces[section]].drinks.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if selectedCategoriesIndeces.count == 0 {
      //check if no categories selected and show placeholder
      if drinkCategories.isEmpty {
        return UITableViewCell()
      }
      
      let cell = UITableViewCell()
      cell.textLabel?.text = "Select some category💃🕺"
      cell.textLabel?.textAlignment = .center
      
      return cell
    }
    
    let currentCategory = drinkCategories[selectedCategoriesIndeces[indexPath.section]]
    if indexPath.row == currentCategory.drinks.count - 1 && indexPath.section + 1 < selectedCategoriesIndeces.count {
      requestSectionDrinks(withIndex: selectedCategoriesIndeces[indexPath.section + 1])
    }
    
    guard let drinkCell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? DrinkTableViewCell else {
      return UITableViewCell()
    }
    
    let drink = currentCategory.drinks[indexPath.row]
    drinkCell.drinkNameLabel.text = drink.name
    drinkCell.drinkImageView?.image = nil
    drinkCell.imageUrl = drink.imageString
    drinkCell.activityIndicator.startAnimating()
    
    NetworkManager.shared.requestForDrinkImage(withUrl: drink.imageString) { image, url in
      DispatchQueue.main.async {
        if drinkCell.imageUrl == url {
          drinkCell.activityIndicator.stopAnimating()
          drinkCell.drinkImageView?.image = image
        }
      }
    }
    
    return drinkCell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if selectedCategoriesIndeces.count == 0 {
      let view = UIView()
      return view
    }
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 28))
    view.backgroundColor = self.view.backgroundColor
    
    let label = UILabel(frame: CGRect(x: 20, y: 10, width: 0, height: 0))
    label.backgroundColor = self.view.backgroundColor
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    label.text = drinkCategories[selectedCategoriesIndeces[section]].name
    label.sizeToFit()
    
    view.addSubview(label)
    
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 28
  }
}
