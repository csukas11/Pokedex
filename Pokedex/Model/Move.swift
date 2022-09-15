//
//  Move.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

struct Move {
  var id = 0
  var name = ""
  
  init() {}
  init(id: Int, name: String) {
    self.id = id
    self.name = name
  }
}
