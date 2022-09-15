//
//  AppDelegate.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import UIKit
import Foundation
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    FirebaseApp.configure()
    let _ = User.instance // start user init
    
    let dispatchGroup = DispatchGroup()
    
    // Load Types
    let typesFetcher = TypesFetcher()
    dispatchGroup.enter()
    typesFetcher.fetch { [weak dispatchGroup] response, error in
      guard let response = response else { return }
      for val in response {
        PokedexDataStore.Types.add(val, forKey: val.id)
      }
      dispatchGroup?.leave()
    }
    
    // Load Abilities
    let abilitiesFetcher = AbilitiesFetcher()
    dispatchGroup.enter()
    abilitiesFetcher.fetch { [weak dispatchGroup] response, error in
      guard let response = response else { return }
      for val in response {
        PokedexDataStore.Abilities.add(val, forKey: val.id)
      }
      dispatchGroup?.leave()
    }
    
    // Load Moves
    let movesFetcher = MovesFetcher()
    dispatchGroup.enter()
    movesFetcher.fetch { [weak dispatchGroup] response, error in
      guard let response = response else { return }
      for val in response {
        PokedexDataStore.Moves.add(val, forKey: val.id)
      }
      dispatchGroup?.leave()
    }
    
    // Load Pokemons
    let pokemonsFetcher = PokemonsFetcher()
    dispatchGroup.enter()
    pokemonsFetcher.fetch { [weak dispatchGroup] response, error in
      guard let response = response else { return }
      for val in response {
        PokedexDataStore.Pokemons.add(val, forKey: val.id)
      }
      dispatchGroup?.leave()
    }
    
    let _ = dispatchGroup.wait()
    
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }


}

