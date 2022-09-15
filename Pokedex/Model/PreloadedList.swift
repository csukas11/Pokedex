//
//  PreloadedList.swift
//  Pokedex
//  Stores items in a thread safe array and allows to filter it by a search keyword
//
//  Created by Tamás Csukás 2022
//

import Foundation

protocol PreloadedListItem {
  var id: Int { get }
  var name: String { get }
}

class PreloadedList<Type: PreloadedListItem> {
  private let dispatchQueue = DispatchQueue(label: "org.csukas.Pokedex.PreloadedList", attributes: .concurrent)
  private var _dataOrder = [Int]()
  private var _data = [Int:Type]()
  
  var items: [Type] {
    var res = [Type]()
    dispatchQueue.sync {
      for key in _dataOrder {
        if let val = _data[key] {
          res.append(val)
        }
      }
    }
    return res
  }
  
  init() {}
  
  init(_ items: [Type]) {
    for item in items {
      add(item, forKey: item.id)
    }
  }
  
  func add(_ value: Type, forKey key: Int) {
    dispatchQueue.async(flags: .barrier) { [weak self] in
      self?._dataOrder.append(key)
      self?._data.updateValue(value, forKey: key)
    }
  }
  
  func remove(forKey key: Int) {
    dispatchQueue.async(flags: .barrier) { [weak self] in
      self?._dataOrder = self?._dataOrder.filter { $0 != key } ?? [Int]()
      self?._data.removeValue(forKey: key)
    }
  }
  
  subscript(_ forKey: Int) -> Type? {
    var res: Type?
    dispatchQueue.sync {
      res = _data[forKey]
    }
    return res
  }
  
  subscript(_ forName: String) -> Type? {
    var res: Type?
    dispatchQueue.sync {
      for (_, val) in _data {
        if val.name == forName {
          res = val
        }
      }
    }
    return res
  }
  
  func search(for keyword: String) -> [Type] {
    var matches = [Type]()
    dispatchQueue.sync {
      for key in _dataOrder {
        if let val = _data[key], (keyword.isEmpty || val.name.lowercased().contains(keyword.lowercased())) {
          matches.append(val)
        }
      }
    }
    return matches
  }
}
