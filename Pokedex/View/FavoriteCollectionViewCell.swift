//
//  PokemonCollectionViewCell.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import Kingfisher
import UIKit

class FavoriteCollectionViewCell: UICollectionViewCell {
  // IBOutlets
  @IBOutlet private weak var labelView: UIView!
  @IBOutlet private weak var label: UILabel!
  
  // MARK: - Properties
  
  var tapOnFavorite: ((Bool) -> Void)?
  
  private var isActive: Bool = false
  
  // MARK: - Functions
  
  func configure(type: String, labelColor: UIColor?, isActive: Bool) {
    self.isActive = isActive
    
    // Modify UI
    labelView.backgroundColor = labelColor ?? UIColor.systemGray4
    labelView.layer.borderWidth = 1
    labelView.layer.cornerRadius = 3.0
    labelView.clipsToBounds = true;
    
    label.text = type
    
    // Add gesture recognizer
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnCell(_:)))
    gestureRecognizer.numberOfTapsRequired = 1
    gestureRecognizer.numberOfTouchesRequired = 1
    labelView.addGestureRecognizer(gestureRecognizer)
    labelView.isUserInteractionEnabled = true
  }
  
  @objc func tapOnCell(_ gesture: UITapGestureRecognizer) {
    isActive = !isActive
    updateUI()
    labelView.setNeedsLayout()
    tapOnFavorite?(isActive)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    updateUI()
  }
  
  private func updateUI() {
    // UI modification
    if isActive {
      labelView.layer.borderColor = UIColor.label.cgColor
    } else {
      labelView.layer.borderColor = labelView.backgroundColor?.cgColor
    }
  }

}
