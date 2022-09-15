//
//  PokedexDataStore.swift
//  Pokedex
//  Stores the pokemons datatset
//
//  Created by Tamás Csukás 2022
//

class PokedexDataStore {
  static let Types = PreloadedList<Type>()
  static let Abilities = PreloadedList<Ability>()
  static let Moves = PreloadedList<Move>()
  static let Pokemons = PreloadedList<PokemonItem>()
}

extension Type: PreloadedListItem {}
extension Ability: PreloadedListItem {}
extension Move: PreloadedListItem {}
extension PokemonItem: PreloadedListItem {}
