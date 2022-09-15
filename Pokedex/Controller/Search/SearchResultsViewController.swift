//
//  SearchResultsViewController.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import UIKit

protocol SearchResultsViewControllerDelegate {
  func favoritesSelected()
  func resultSelected(result: String)
  func typeSelected(type: String)
  func abilitySelected(ability: String)
  func moveSelected(move: String)
}

class SearchResultsViewController: UIViewController {
  
  // IBOutlets
  @IBOutlet private weak var tableView: UITableView!
  
  // MARK: - Properties
  
  var delegate: SearchResultsViewControllerDelegate?
  
  private var resultsList: [String] = [String]()
  private var typesList: [String] = [String]()
  private var abilitiesList: [String] = [String]()
  private var movesList: [String] = [String]()
  
  // MARK: - Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(SearchResultsTableViewCell.nib(), forCellReuseIdentifier: SearchResultsTableViewCell.identifier)
    tableView.delegate = self
    tableView.dataSource = self
    
    // Managing keyboard
    startAvoidingKeyboard()
    
    // UI modifications
    tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
  }
  
  func setSearchResults(_ results: [String]) {
    resultsList = results
    tableView.reloadSections(IndexSet(integer: 1), with: .none)
  }
  
  func setSearchTypes(_ types: [String]) {
    typesList = types
    tableView.reloadSections(IndexSet(integer: 2), with: .none)
  }
  
  func setSearchAbilities(_ abilities: [String]) {
    abilitiesList = abilities
    tableView.reloadSections(IndexSet(integer: 3), with: .none)
  }
  
  func setSearchMoves(_ moves: [String]) {
    movesList = moves
    tableView.reloadSections(IndexSet(integer: 4), with: .none)
  }
  
  // MARK: - Nib
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  static func nib() -> UINib {
    return UINib(nibName: "SearchResultsViewController", bundle: nil)
  }
  
}

// MARK: - UITableViewDelegate

extension SearchResultsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch indexPath.section {
    case 0:
      delegate?.favoritesSelected()
    case 1:
      delegate?.resultSelected(result: resultsList[indexPath.row])
    case 2:
      delegate?.typeSelected(type: typesList[indexPath.row])
    case 3:
      delegate?.abilitySelected(ability: abilitiesList[indexPath.row])
    case 4:
      delegate?.moveSelected(move: movesList[indexPath.row])
    default:
      print("Section not implemented...")
    }
  }
}

// MARK: - UITableViewDataSource

extension SearchResultsViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 5
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return nil
    case 1:
      return "Search results"
    case 2:
      return "Types"
    case 3:
      return"Abilities"
    case 4:
      return "Moves"
    default:
      print("Section not implemented...")
      return ""
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 1
    }
    return 36
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 30
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return resultsList.count
    case 2:
      return typesList.count
    case 3:
      return abilitiesList.count
    case 4:
      return movesList.count
    default:
      print("Section not implemented...")
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTableViewCell.identifier, for: indexPath) as? SearchResultsTableViewCell else { return SearchResultsTableViewCell() }
    
    switch indexPath.section {
    case 0:
      cell.iconImageView.image = UIImage(systemName: "heart.fill")
      cell.label.text = "Favorites"
    case 1:
      cell.iconImageView.image = UIImage(systemName: "magnifyingglass")
      cell.label.text = resultsList[indexPath.row]
    case 2:
      cell.iconImageView.image = UIImage(systemName: "line.horizontal.3.decrease")
      cell.label.text = typesList[indexPath.row]
    case 3:
      cell.iconImageView.image = UIImage(systemName: "line.horizontal.3.decrease")
      cell.label.text = abilitiesList[indexPath.row]
    case 4:
      cell.iconImageView.image = UIImage(systemName: "line.horizontal.3.decrease")
      cell.label.text = movesList[indexPath.row]
    default:
      cell.iconImageView.image = UIImage(systemName: "magnifyingglass")
      cell.label.text = ""
    }
    
    return cell
  }
  
  
}
