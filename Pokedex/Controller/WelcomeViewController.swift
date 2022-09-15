//
//  WelcomeViewController.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import UIKit
import KTCenterFlowLayout

class WelcomeViewController: UIViewController {
  
  // IBOutlets
  @IBOutlet private weak var nameTextFieldView: UIView!
  @IBOutlet private weak var nameTextField: UITextField!
  @IBOutlet private weak var favoriteCollectionView: UICollectionView!
  @IBOutlet private weak var saveButton: UIButton!
  @IBOutlet private weak var favoriteCollectionViewHeight: NSLayoutConstraint!
  
  
  // IBActions
  @IBAction private func onSave(_ sender: UIButton) {
    performSegue(withIdentifier: "ToSearch", sender: nil)
  }
  
  @IBAction private func searchTextFieldDidChange(_ sender: Any) {
    User.instance.username = nameTextField.text ?? ""
  }
  
  // MARK: Properties
  
  private var typeList = PokedexDataStore.Types.items
  
  /*private var username: String {
    get {
      // Load username from storage
      let defaults = UserDefaults.standard
      if let name = defaults.string(forKey: "username") {
        return name
      } else {
        defaults.set([Int](), forKey: "username")
        return ""
      }
    }
    set {
      // Save username to storage
      let defaults = UserDefaults.standard
      defaults.set(newValue, forKey: "username")
    }
  }
  private var favoriteTypes: [Int] {
    get {
      // Load user favorite types from storage
      let defaults = UserDefaults.standard
      if let favs = defaults.object(forKey: "favoriteTypes") as? [Int] {
        return favs
      } else {
        defaults.set([Int](), forKey: "favoriteTypes")
        return [Int]()
      }
    }
    set {
      // Save user favorite types to storage
      let defaults = UserDefaults.standard
      defaults.set(newValue, forKey: "favoriteTypes")
    }
  }*/
  
  // MARK: Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    favoriteCollectionView.dataSource = self
    
    nameTextField.text = User.instance.username
    
    // Hide keyboard
    self.hideKeyboardWhenTappedAround()
    
    // set layout for collection view
    let layout = favoriteCollectionView.collectionViewLayout as? KTCenterFlowLayout
    //layout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    layout?.minimumInteritemSpacing = 10.0
    layout?.minimumLineSpacing = 10.0
    
    // UI modifications
    nameTextFieldView.layer.borderColor = UIColor.label.cgColor
    nameTextFieldView.layer.borderWidth = 1
    nameTextFieldView.layer.cornerRadius = 9.0
    nameTextFieldView.clipsToBounds = true
    
    nameTextField.borderStyle = .none
    
    saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    saveButton.layer.cornerRadius = 16.0
    saveButton.clipsToBounds = true
    
    self.favoriteCollectionViewHeight.constant = min(self.favoriteCollectionView.collectionViewLayout.collectionViewContentSize.height, 200)
    
    self.view.layoutIfNeeded()
  }
}

// MARK: UICollectionViewDataSource

extension WelcomeViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return typeList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // prepare cell for display
    let cell = favoriteCollectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCollectionViewCell", for: indexPath) as! FavoriteCollectionViewCell
    let item = typeList[indexPath.row]
    
    cell.configure(type: item.name, labelColor: nil, isActive: User.instance.isFavoriteType(id: item.id))
    cell.tapOnFavorite = { isActive in
      let id = item.id
      if isActive {
        User.instance.setFavoriteType(id: id)
      } else {
        User.instance.unsetFavoriteType(id: id)
      }
    }
    
    return cell
  }
}
