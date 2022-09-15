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
}
