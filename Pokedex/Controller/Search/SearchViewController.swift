//
//  SearchViewController.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import UIKit

extension SearchViewController {
  enum ViewMode {
    case searchResults, search
  }
}

class SearchViewController: UIViewController {
  
  // IBOutlets
  @IBOutlet weak var resultsViewHeightConstraint: NSLayoutConstraint!
  
  // IBActions
  @IBAction func unwind( _ seg: UIStoryboardSegue) {}
  
  // MARK: - Properties
  
  // The view state
  private var viewMode: ViewMode = .search {
    didSet {
      guard oldValue != viewMode else { return }
      switch viewMode {
      case .searchResults:
        // view.backgroundColor = UIColor(red: 250.0/255, green: 250.0/255, blue: 250.0/255, alpha: 1.0)
        showResultsView()
      case .search:
        // view.backgroundColor = UIColor.white
        loadPokemons()
        hideResultsView()
      }
    }
  }
  
  // Var to temporarily store selected item's id
  private var selectedID = 0
  
  // Embedded VCs
  private var searchBarVC: SearchBarViewController!
  private var resultsVC: SearchResultsViewController!
  private var collectionVC: PokemonCollectionViewController!
  
  // Search state props
  private var searchKeyword = ""
  private var currentPage = 1
  private let itemsPerPage = 20
  private var pokemonsToFilter = PreloadedList<PokemonItem>()
  private var pokemonsToDisplay = [Int]()
  
  // Fetchers to load data
  private let pokemonsFetcher = PokemonsFetcher()
  private let typesFetcher = TypesFetcher()
  private let abilitiesFetcher = AbilitiesFetcher()
  private let movesFetcher = MovesFetcher()
  
  // MARK: - Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pokemonsToFilter = PokedexDataStore.Pokemons
    pokemonsToDisplay = pokemonsToFilter.items.map { $0.id }
    loadPokemons()
    
    resultsVC.setSearchResults([])
    resultsVC.setSearchTypes([String](PokedexDataStore.Types.items.map { $0.name }.prefix(10)))
    resultsVC.setSearchAbilities([String](PokedexDataStore.Abilities.items.map { $0.name }.prefix(10)))
    resultsVC.setSearchMoves([String](PokedexDataStore.Moves.items.map { $0.name }.prefix(10)))
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ToSearchBar" {
      guard let viewController = segue.destination as? SearchBarViewController else { return }
      searchBarVC = viewController
      searchBarVC.delegate = self
    } else if segue.identifier == "ToSearchResults" {
      guard let viewController = segue.destination as? SearchResultsViewController else { return }
      resultsVC = viewController
      resultsVC.delegate = self
    } else if segue.identifier == "ToSearch" {
      guard let viewController = segue.destination as? PokemonCollectionViewController else { return }
      collectionVC = viewController
      collectionVC.setDelegate(self)
    } else if segue.identifier == "ToDetails" {
      guard let viewController = segue.destination as? DetailsViewController else { return }
      viewController.pokemonID = selectedID
      viewController.onDismissCallback = { [weak self] in
        self?.collectionVC.reload()
      }
    }
  }
  
  private func loadPokemons(page: Int = 1) {
    guard ((page - 1) * itemsPerPage) <= pokemonsToDisplay.count else { return } // exit if page exceeds the max page number
    
    currentPage = page
    if page == 1 {
      pokemonsFetcher.dismissFetching()
      collectionVC.clearItems(reload: false)
    }
    
    let idsRange = (from: ((page - 1) * itemsPerPage), to: min(pokemonsToDisplay.count, (page * itemsPerPage)))
    var loadedPokemons = [Int: Pokemon?]()
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "org.csukas.Pokedex.SearchViewController")

    // load pokemon details
    for i in idsRange.from ..< idsRange.to {
      let id = pokemonsToDisplay[i]
      dispatchGroup.enter()
      loadedPokemons.updateValue(nil, forKey: id)
      pokemonsFetcher.fetchPokemon(id) { [weak dispatchGroup, weak dispatchQueue] response, error in
        guard let response = response, let dispatchGroup = dispatchGroup, let dispatchQueue = dispatchQueue else { return }
        dispatchQueue.sync {
          loadedPokemons.updateValue(response, forKey: response.id)
          dispatchGroup.leave()
        }
      }
    }
    dispatchGroup.wait()
    
    // add pokemons to the collection view controller
    for i in idsRange.from ..< idsRange.to {
      let id = pokemonsToDisplay[i]
      let val = loadedPokemons[id]!!
      collectionVC.addItem(PokemonCollectionViewController.ListItem(
        id: val.id,
        name: val.name,
        imageURL: val.imageURLs["front_male"] ?? "",
        type: val.type,
        typeLabelColor: UIColor.systemGray4,
        hp: val.hp,
        def: val.def,
        atk: val.atk,
        sp: val.sp
      ))
    }
    collectionVC.reload()
  }

  // MARK: - Animations

  // Hide results view and show search view
  private func hideResultsView() {
    UIView.animate(withDuration: 0.1) {
      self.resultsViewHeightConstraint.priority = UILayoutPriority.required
      self.view.layoutIfNeeded()
    }
  }

  // Show results view and hide search view
  private func showResultsView() {
    UIView.animate(withDuration: 0.1) {
      self.resultsViewHeightConstraint.priority = UILayoutPriority.init(1)
      self.view.layoutIfNeeded()
    }
  }
  
}

// MARK: - SearchBarViewControllerDelegate

extension SearchViewController: SearchBarViewControllerDelegate {
  func clearFilter() {
    pokemonsToFilter = PokedexDataStore.Pokemons // set filter to its default
    search(for: searchKeyword) // filter pokemons according to the search keyword
    if viewMode == .search {
      loadPokemons() // display results
    }
  }
  
  func search(for keyword: String?) {
    if let keyword = keyword, !keyword.isEmpty {
      searchKeyword = keyword
      resultsVC.setSearchResults(
        [String](pokemonsToFilter.search(for: keyword).map { $0.name }.prefix(10))
      )
      resultsVC.setSearchTypes(
        [String](PokedexDataStore.Types.search(for: keyword).map { $0.name }.prefix(10))
      )
      resultsVC.setSearchAbilities(
        [String](PokedexDataStore.Abilities.search(for: keyword).map { $0.name }.prefix(10))
      )
      resultsVC.setSearchMoves(
        [String](PokedexDataStore.Moves.search(for: keyword).map { $0.name }.prefix(10))
      )
    } else {
      searchKeyword = ""
      resultsVC.setSearchResults([])
      resultsVC.setSearchTypes([String](PokedexDataStore.Types.items.map { $0.name }.prefix(10)))
      resultsVC.setSearchAbilities([String](PokedexDataStore.Abilities.items.map { $0.name }.prefix(10)))
      resultsVC.setSearchMoves([String](PokedexDataStore.Moves.items.map { $0.name }.prefix(10)))
    }
    
    if searchKeyword == "Favorites" {
      // load favorites
      pokemonsToFilter = PokedexDataStore.Pokemons
      pokemonsToDisplay = User.instance.favoritePokemons
    } else {
      // filter pokemons according to the search keyword
      pokemonsToDisplay = pokemonsToFilter.search(for: searchKeyword).map { $0.id }
    }
  }
  
  func beginEditing() {
    viewMode = .searchResults
  }
  
  func endEditing() {
    viewMode = .search
  }
}

// MARK: - SearchResultsViewControllerDelegate

extension SearchViewController: SearchResultsViewControllerDelegate {
  func favoritesSelected() {
    // modify search bar
    searchBarVC.setFilter(text: "")
    searchBarVC.searchKeyword = "Favorites"
    search(for: "")
    view.endEditing(false)
    // load favorites
    pokemonsToFilter = PokedexDataStore.Pokemons
    pokemonsToDisplay = User.instance.favoritePokemons
    searchBarVC.status = .inactive
  }
  
  func resultSelected(result: String) {
    // update search keyword
    searchKeyword = result
    searchBarVC.searchKeyword = result
    view.endEditing(false)
    // load favorite pokemons
    pokemonsToDisplay = pokemonsToFilter.search(for: searchKeyword).map { $0.id }
    searchBarVC.status = .inactive
  }
  
  func typeSelected(type: String) {
    let dg = DispatchGroup()
    dg.enter()
    typesFetcher.fetchPokemons(for: PokedexDataStore.Types[type]!.id) { [weak self, weak dg] result, error in
      guard let result = result else { return }
      self?.pokemonsToFilter = PreloadedList<PokemonItem>(result)
      dg?.leave()
    }
    let _ = dg.wait(timeout: .now() + 10)
    searchBarVC.setFilter(text: type)
    searchBarVC.searchKeyword = ""
    search(for: "")
  }
  
  func abilitySelected(ability: String) {
    let dg = DispatchGroup()
    dg.enter()
    abilitiesFetcher.fetchPokemons(for: PokedexDataStore.Abilities[ability]!.id) { [weak self, weak dg] result, error in
      guard let result = result else { return }
      self?.pokemonsToFilter = PreloadedList<PokemonItem>(result)
      dg?.leave()
    }
    let _ = dg.wait(timeout: .now() + 10)
    searchBarVC.setFilter(text: ability)
    searchBarVC.searchKeyword = ""
    search(for: "")
  }
  
  func moveSelected(move: String) {
    let dg = DispatchGroup()
    dg.enter()
    movesFetcher.fetchPokemons(for: PokedexDataStore.Moves[move]!.id) { [weak self, weak dg] result, error in
      guard let result = result else { return }
      self?.pokemonsToFilter = PreloadedList<PokemonItem>(result)
      dg?.leave()
    }
    let _ = dg.wait(timeout: .now() + 10)
    searchBarVC.setFilter(text: move)
    searchBarVC.searchKeyword = ""
    search(for: "")
  }
}

// MARK: - PokemonCollectionDelegate

extension SearchViewController: PokemonCollectionDelegate {
  func loadNextPage(identifier: String) {
    loadPokemons(page: currentPage + 1)
  }
  
  func itemSelected(_ id: Int, identifier: String) {
    selectedID = id
    performSegue(withIdentifier: "ToDetails", sender: nil)
  }
}
