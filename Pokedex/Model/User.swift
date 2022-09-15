//
//  User.swift
//  Pokedex
//  User authentication and data storage based on Firebase
//
//  Created by Tamás Csukás 2022
//

import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class User {
  
  // MARK: Properties
  
  static let instance = User()
  
  private var provider = OAuthProvider(providerID: "github.com")
  private lazy var db = Firestore.firestore()
  
  private var uid = ""
  
  private var _isAuthenticated = false
  var isAuthenticated: Bool { _isAuthenticated }
  
  var notifyWhenReady: (() -> Void)? = nil
  
  private var _username = ""
  var username: String {
    get {
      return _username
    }
    set {
      guard isAuthenticated && !uid.isEmpty else { return }
      _username = newValue
      db.collection("users").document(self.uid).setData([
        "username": _username,
        "favoriteTypes": _favoriteTypes,
        "favoritePokemons": _favoritePokemons
      ]) { err in
        if let err = err {
          print("Error writing document: \(err)")
        }
      }
    }
  }
  
  private var _favoriteTypes = [Int]()
  var favoriteTypes: [Int] {
    get {
      return _favoriteTypes
    }
    set {
      guard isAuthenticated && !uid.isEmpty else { return }
      _favoriteTypes = newValue
      db.collection("users").document(self.uid).setData([
        "username": _username,
        "favoriteTypes": _favoriteTypes,
        "favoritePokemons": _favoritePokemons
      ]) { err in
        if let err = err {
          print("Error writing document: \(err)")
        }
      }
    }
  }
  
  private var _favoritePokemons = [Int]()
  var favoritePokemons: [Int] {
    get {
      return _favoritePokemons
    }
    set {
      guard isAuthenticated && !uid.isEmpty else { return }
      _favoritePokemons = newValue
      db.collection("users").document(self.uid).setData([
        "username": _username,
        "favoriteTypes": _favoriteTypes,
        "favoritePokemons": _favoritePokemons
      ]) { err in
        if let err = err {
          print("Error writing document: \(err)")
        }
      }
    }
  }
  
  // MARK: Functions
  
  private init() {
    Auth.auth().addStateDidChangeListener { [weak self] auth, user in
      guard let self = self else { return }
      if let user = user {
        self.uid = user.uid
        self.createDocumentIfNotExists() { [weak self] _ in
          self?._isAuthenticated = true
          self?.notifyWhenReady?()
        }
        self.registerDocumentListener()
      } else {
        self._isAuthenticated = false
        self.notifyWhenReady?()
      }
    }
  }
  
  func authenticate(completion: ((_ isAuthenticated: Bool) -> Void)? = nil) {
    guard !isAuthenticated else {
      completion?(true)
      return
    }
    provider.getCredentialWith(nil) { [weak self] credential, error in
      if let error = error {
        // Handle error.
        print("Can't get credentials from provider: \(error)")
        completion?(false)
      }
      if let credential = credential {
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
          guard let self = self else { return }
          
          if let error = error {
            // Handle error.
            print("Can't log in via Github: \(error)")
            completion?(false)
          }
          
          // User is signed in.
          self.createDocumentIfNotExists(completion: completion)
          self.registerDocumentListener()
        }
      } else {
        completion?(false)
      }
    }
  }
  
  func logout() {
    let _ = try? Auth.auth().signOut()
    _isAuthenticated = false
    uid = ""
    _username = ""
    _favoriteTypes = []
    _favoritePokemons = []
  }
  
  private func createDocumentIfNotExists(completion: ((_ isAuthenticated: Bool) -> Void)? = nil) {
    guard !uid.isEmpty else { return }
    
    let docRef = db.collection("users").document(uid)

    docRef.getDocument { [weak self] (document, error) in
      guard let self = self else { return }
      if let document = document, document.exists {
        guard let data = document.data() else {
          print("Document data was empty.")
          completion?(false)
          return
        }
        self._username = data["username"] as? String ?? ""
        self._favoriteTypes = data["favoriteTypes"] as? [Int] ?? [Int]()
        self._favoritePokemons = data["favoritePokemons"] as? [Int] ?? [Int]()
        completion?(true)
      } else {
        self.db.collection("users").document(self.uid).setData([
          "username": "",
          "favoriteTypes": [Int](),
          "favoritePokemons": [Int]()
        ]) { err in
          if let err = err {
            print("Error writing document: \(err)")
          }
        }
        completion?(true)
      }
    }
  }
  
  private func registerDocumentListener() {
    guard !uid.isEmpty else { return }
    
    db.collection("users").document(uid)
    .addSnapshotListener { [weak self] documentSnapshot, error in
      guard let self = self else { return }
      guard let document = documentSnapshot else {
        print("Error fetching document: \(error!)")
        return
      }
      guard let data = document.data() else {
        print("Document data was empty.")
        return
      }
      self._username = data["username"] as? String ?? ""
      self._favoriteTypes = data["favoriteTypes"] as? [Int] ?? [Int]()
      self._favoritePokemons = data["favoritePokemons"] as? [Int] ?? [Int]()
    }
  }
  
  // MARK: Favorite Types
  
  func isFavoriteType(id: Int) -> Bool {
    return _favoriteTypes.contains(id)
  }
  
  func setFavoriteType(id: Int) {
    guard !_favoriteTypes.contains(id) else { return }
    _favoriteTypes.append(id)
    favoriteTypes = _favoriteTypes
  }
  
  func unsetFavoriteType(id: Int) {
    guard _favoriteTypes.contains(id) else { return }
    _favoriteTypes = _favoriteTypes.filter { $0 != id }
    favoriteTypes = _favoriteTypes
  }
  
  // MARK: Favorite Pokemons
  
  func isFavoritePokemon(id: Int) -> Bool {
    return _favoritePokemons.contains(id)
  }
  
  func setFavoritePokemon(id: Int) {
    guard !_favoritePokemons.contains(id) else { return }
    _favoritePokemons.append(id)
    favoritePokemons = _favoritePokemons
  }
  
  func unsetFavoritePokemon(id: Int) {
    guard _favoritePokemons.contains(id) else { return }
    _favoritePokemons = _favoritePokemons.filter { $0 != id }
    favoritePokemons = _favoritePokemons
  }
}
