//
//  DetailsViewController.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import Kingfisher
import UIKit

extension DetailsViewController {
  enum Sex: String {
    case male, female
  }
  
  enum PreviewOrientation: String {
    case back, front
  }
}

class DetailsViewController: UIViewController {
  
  // IBOutlets
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var typeLabelView: UIView!
  @IBOutlet private weak var typeLabel: UILabel!
  @IBOutlet private weak var hpLabel: UILabel!
  @IBOutlet private weak var defLabel: UILabel!
  @IBOutlet private weak var atkLabel: UILabel!
  @IBOutlet private weak var spLabel: UILabel!
  @IBOutlet private weak var femaleImageView: UIView!
  @IBOutlet private weak var maleImageView: UIView!
  @IBOutlet private weak var backButton: UIButton!
  @IBOutlet private weak var frontButton: UIButton!
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var favoriteButton: UIButton!
  
  // IBActions
  @IBAction private func onClose(_ sender: UIButton) {
    onDismissCallback?()
    performSegue(withIdentifier: "unwindToSearch", sender: self)
  }
  @IBAction private func onFavorite(_ sender: UIButton) {
    isFavorite = !isFavorite
    updateFavoriteUI()
    view.setNeedsLayout()
    view.layoutIfNeeded()
  }
  @IBAction private func onFemale(_ sender: UIButton) {
    previewSex = .female
  }
  @IBAction private func onMale(_ sender: UIButton) {
    previewSex = .male
  }
  @IBAction private func onBack(_ sender: UIButton) {
    previewOrientation = .back
  }
  @IBAction private func onFront(_ sender: UIButton) {
    previewOrientation = .front
  }
  
  // MARK: Properties
  
  var pokemonID = 0
  private var pokemon: Pokemon?
  
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
  
  private var previewSex: Sex = .female {
    didSet {
      guard updateImage() else {
        // If the image version is not available, then set the value back to the previous one
        previewSex = oldValue == .female ? .female : .male
        return
      }
      if previewSex == .female {
        femaleImageView.alpha = 1.0
        maleImageView.alpha = 0.5
      } else {
        femaleImageView.alpha = 0.5
        maleImageView.alpha = 1.0
      }
      view.setNeedsLayout()
      view.layoutIfNeeded()
    }
  }
  
  private var previewOrientation: PreviewOrientation = .back {
    didSet {
      guard updateImage() else {
        // If the image version is not available, then set the value back to the previous one
        previewOrientation = oldValue == .back ? .back : .front
        return
      }
      if previewOrientation == .back {
        backButton.titleLabel?.font = .boldSystemFont(ofSize: 15.0)
        frontButton.titleLabel?.font = .systemFont(ofSize: 15.0)
      } else {
        backButton.titleLabel?.font = .systemFont(ofSize: 15.0)
        frontButton.titleLabel?.font = .boldSystemFont(ofSize: 15.0)
      }
      view.setNeedsLayout()
      view.layoutIfNeeded()
    }
  }
  
  // Called when the view is being dismissed
  var onDismissCallback: (() -> Void)?
  
  // Fetcher to load data
  private let pokemonsFetcher = PokemonsFetcher()
  
  // MARK: Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // UI modification
    containerView.layer.borderColor = UIColor.label.cgColor
    containerView.layer.borderWidth = 1
    containerView.layer.cornerRadius = 18.0
    containerView.clipsToBounds = true;
    typeLabelView.layer.cornerRadius = 3.0
    typeLabelView.clipsToBounds = true;
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    contentView.alpha = 0 // hide content while loading
    loadData()
  }
  
  private func loadData() {
    pokemonsFetcher.fetchPokemon(pokemonID) { response, error in
      guard let response = response else { return }
      
      DispatchQueue.main.async { [weak self] in
        self?.pokemon = response
        self?.updateUI()
      }
    }
  }
  
  private func updateUI() {
    guard let pokemon = pokemon else { return }
    
    // Update pokemons data
    nameLabel.text = pokemon.name
    typeLabel.text = pokemon.type
    typeLabelView.backgroundColor = UIColor.systemGray4
    hpLabel.text = "Hp \(pokemon.hp)"
    defLabel.text = "Def \(pokemon.def)"
    atkLabel.text = "Atk \(pokemon.atk)"
    spLabel.text = "Sp \(pokemon.sp)"
    
    // Favorite
    updateFavoriteUI()
    
    // Update image
    if pokemon.imageURLs["back_female"] != nil {
      previewSex = .female
      previewOrientation = .back
    } else if pokemon.imageURLs["front_female"] != nil {
      previewSex = .female
      previewOrientation = .front
    } else if pokemon.imageURLs["back_male"] != nil {
      previewSex = .male
      previewOrientation = .back
    } else if pokemon.imageURLs["front_male"] != nil {
      previewSex = .male
      previewOrientation = .front
    }
    let _ = updateImage()
    contentView.alpha = 1 // show content when loaded
    view.layoutIfNeeded()
  }
  
  // Update favorite UI based on it's current state
  private func updateFavoriteUI() {
    if isFavorite {
      favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
    } else {
      favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
  }
  
  // Update image based on the current previewOrientation and previewSex.
  // Returns if the image version is available
  private func updateImage() -> Bool {
    if let imageURL = pokemon?.imageURLs[previewOrientation.rawValue + "_" + previewSex.rawValue] {
      if let url = URL(string: imageURL) {
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
      return true
    }
    return false
  }
}
