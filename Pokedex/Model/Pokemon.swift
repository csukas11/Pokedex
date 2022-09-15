//
//  Pokemon.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import Foundation

struct Pokemon {
  var id = 0
  var name = ""
  var imageURLs = Dictionary<String, String>()
  var type = ""
  var hp = 0
  var def = 0
  var atk = 0
  var sp = 0
  
  init() {}
  init(id: Int, name: String, imageURLs: Dictionary<String, String>, type: String, hp: Int, def: Int, atk: Int, sp: Int) {
    self.id = id
    self.name = name
    self.imageURLs = imageURLs
    self.type = type
    self.hp = hp
    self.def = def
    self.atk = atk
    self.sp = sp
  }
  
  /* static func getFavorites() -> [Int] {
    let defaults = UserDefaults.standard
    guard let favorites = defaults.object(forKey: "favoritePokemons") as? [Int] else { return [] }
    return favorites
  }
  
  static func isFavorite(id: Int) -> Bool {
    let defaults = UserDefaults.standard
    guard let favorites = defaults.object(forKey: "favoritePokemons") as? [Int] else {
      return false
    }
    return favorites.contains(id)
  }
  
  static func setFavorite(id: Int) {
    let defaults = UserDefaults.standard
    if var favorites = defaults.object(forKey: "favoritePokemons") as? [Int] {
      guard !favorites.contains(id) else { return }
      favorites.append(id)
      defaults.set(favorites, forKey: "favoritePokemons")
    } else {
      defaults.set([id], forKey: "favoritePokemons")
    }
  }
  
  static func unsetFavorite(id: Int) {
    let defaults = UserDefaults.standard
    if var favorites = defaults.object(forKey: "favoritePokemons") as? [Int] {
      favorites = favorites.filter { $0 != id }
      defaults.set(favorites, forKey: "favoritePokemons")
    }
  }*/
}
