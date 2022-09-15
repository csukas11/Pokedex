//
//  SearchResultsTableViewCell.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {
  
  // IBOutlets
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var label: UILabel!
  
  // MARK: - Properties
  
  static let identifier = "SearchResultsTableViewCell"
  
  // MARK: - Nib
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  static func nib() -> UINib {
    return UINib(nibName: identifier, bundle: nil)
  }
  
}
