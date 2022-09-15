//
//  PokemonCollectionViewController.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import UIKit

protocol PokemonCollectionDelegate: AnyObject {
  // Called when an item is selected by the user
  func itemSelected(_ id: Int, identifier: String)
  
  // Called when it is time to load the next page
  func loadNextPage(identifier: String)
}

extension PokemonCollectionViewController {
  class ListItem {
    var id: Int
    var name: String
    var imageURL: String
    var type: String
    var typeLabelColor: UIColor?
    var hp: Int
    var def: Int
    var atk: Int
    var sp: Int
    
    init(id: Int, name: String, imageURL: String, type: String, typeLabelColor: UIColor?, hp: Int, def: Int, atk: Int, sp: Int) {
      self.id = id
      self.name = name
      self.imageURL = imageURL
      self.type = type
      self.typeLabelColor = typeLabelColor
      self.hp = hp
      self.def = def
      self.atk = atk
      self.sp = sp
    }
  }
}

class PokemonCollectionViewController: UICollectionViewController  {
  
  // Margins for the Collection View
  var marginTopBottom: CGFloat = 20
  var marginLeftRight: CGFloat = 20
  var marginBetweenItems: CGFloat = 20
  
  ///------------------------------------------------------------------
  
  // MARK: - Properties
  
  // Size of the cells
  var spacing: CGFloat { marginBetweenItems }
  var cellWidth: Double { Double((UIScreen.main.bounds.size.width - marginLeftRight * 2 - spacing) / 2) }
  var cellHeight: Double { Double(cellWidth * (47/30)) }
  
  // Delegate
  private var identifier = ""
  private weak var delegate: PokemonCollectionDelegate?
  
  // Refresh Control
  weak var refreshControl: UIRefreshControl?
  
  // Array to store displayed items
  private var _data: [ListItem] = [ListItem]()
  // Number of items in the collection view
  var itemCount: Int { _data.count }
  
  // MARK: - Funcitons
  
  // Set the delegate
  func setDelegate(_ delegate: PokemonCollectionDelegate, identifier: String = "") {
    self.identifier = identifier
    self.delegate = delegate
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.register(PokemonCollectionViewCell.nib(), forCellWithReuseIdentifier: PokemonCollectionViewCell.identifier)
    
    // set direction
    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.scrollDirection = .vertical
    }
    
    // set delegates
    collectionView.dataSource = self
    collectionView.delegate = self
    
    // Init margins depending on the display's type
    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//      if UIDevice.current.hasNotch {
          layout.sectionInset = UIEdgeInsets(
            top: marginTopBottom,
            left: marginLeftRight,
            bottom: marginTopBottom,
            right: marginLeftRight
          )
//      }
      
      layout.minimumInteritemSpacing = self.spacing
      layout.minimumLineSpacing = self.spacing
      
      layout.invalidateLayout()
      
      // Set refresh control
      if let refreshControl = refreshControl {
        collectionView.refreshControl = refreshControl
      }
    }
  }
  
  // MARK: - Collection View Data manipulation
  
  // Add a single item to the colleciton view
  func addItem(_ item: ListItem) {
    collectionView.performBatchUpdates({
      let indexPath = IndexPath(row: self._data.count, section: 0)
      self._data.append(item)
      collectionView.insertItems(at: [indexPath])
    }, completion: nil)
  }
  
  // Add an array of items to the collection view
  func addItems(_ items: [ListItem]) {
    for item in items {
      addItem(item)
    }
  }
  
  // Remove all items from the collection view
  func clearItems(reload: Bool = true) {
    _data = []
    if reload {
      self.reload()
    }
  }
  
  // Refresh details
  func reload() {
    collectionView.reloadData()
  }
  
  // MARK: - UICollectionViewDataSource
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return _data.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // Load next page if the last item is displayed
    if indexPath.row != 0 && indexPath.row == (self.itemCount - 1) {
      delegate?.loadNextPage(identifier: identifier)
    }
    
    // prepare cell for display
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonCollectionViewCell.identifier, for: indexPath) as! PokemonCollectionViewCell
    let item = _data[indexPath.row]
    cell.configure(with: item)
    
    return cell
  }

  // MARK: - UICollectionViewDelegate

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    
    delegate?.itemSelected(_data[indexPath.row].id, identifier: self.identifier)
  }
}
  
// MARK: - UICollectionViewDelegateFlowLayout
  
extension PokemonCollectionViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    return CGSize(width: cellWidth, height: cellHeight)
  }
  
}

// MARK: - UIDevice.hasNotch
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
