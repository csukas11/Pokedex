//
//  PokemonCollectionViewCell.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import Kingfisher
import UIKit

class PokemonCollectionViewCell: UICollectionViewCell {
  // IBOutlets
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var imageContainerView: UIView!
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var favoriteButton: UIButton!
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var typeLabelView: UIView!
  @IBOutlet private weak var typeLabel: UILabel!
  @IBOutlet private weak var hpLabel: UILabel!
  @IBOutlet private weak var defLabel: UILabel!
  @IBOutlet private weak var atkLabel: UILabel!
  @IBOutlet private weak var spLabel: UILabel!
  
  // IBActions
  @IBAction func tapOnFavorite(_ sender: Any) {
    isFavorite = !isFavorite
    updateFavoriteUI()
  }
  
  // MARK: - Properties
  
  static let identifier = "PokemonCollectionViewCell"
  
  private var pokemonID = 0
  
  private var isFavorite: Bool {
    get {
      return User.instance.isFavoritePokemon(id: pokemonID)
    }
    set {
      if newValue {
        User.instance.setFavoritePokemon(id: pokemonID)
      } else {
        User.instance.unsetFavoritePokemon(id: pokemonID)
      }
    }
  }
  
  // MARK: - Functions
  
  func configure(with pokemon: PokemonCollectionViewController.ListItem) {
    pokemonID = pokemon.id
    
    if !pokemon.imageURL.isEmpty {
      if let url = URL(string: pokemon.imageURL) {
        let processor = DownsamplingImageProcessor(size:imageView.frame.size)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
        ])
      }
    } else {
      imageView.image = nil
    }
    
    updateFavoriteUI()
    
    nameLabel.text = pokemon.name
    typeLabel.text = pokemon.type
    typeLabelView.backgroundColor = pokemon.typeLabelColor ?? UIColor.systemGray4
    hpLabel.text = "Hp \(pokemon.hp)"
    defLabel.text = "Def \(pokemon.def)"
    atkLabel.text = "Atk \(pokemon.atk)"
    spLabel.text = "Sp \(pokemon.sp)"
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // UI modification
    containerView.layer.borderColor = UIColor.label.cgColor
    containerView.layer.borderWidth = 1
    containerView.layer.cornerRadius = 8.0
    containerView.clipsToBounds = true;
    imageContainerView.layer.cornerRadius = 8.0
    imageContainerView.clipsToBounds = true;
    typeLabelView.layer.cornerRadius = 3.0
    typeLabelView.clipsToBounds = true;
  }
  
  private func updateFavoriteUI() {
    if isFavorite {
      favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
    } else {
      favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  static func nib() -> UINib {
    return UINib(nibName: "PokemonCollectionViewCell", bundle: nil)
  }

}
