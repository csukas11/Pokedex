//
//  AbilitiesFetcher.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import Moya
import Alamofire
import Kingfisher

class AbilitiesFetcher {
  var provider = MoyaProvider<PokeAPI>(callbackQueue: DispatchQueue.global(qos: .userInitiated)) //MoyaProvider<PokeAPI>(plugins: [NetworkLoggerPlugin()])
  
  func fetch(completion: @escaping ([Ability]?, APIError?) -> Void) {
    provider.request(.abilities) { result in
      switch result {
      case let .success(response):
        do {
          let results = try JSONDecoder().decode(APIAbilitiesResponse.self, from: response.data)
          
          var convertedListItems = [Ability]()
          
          for item in results.results {
            if let id = PokeAPI.getIDFromURL(item.url) {
              convertedListItems.append(
                Ability(id: id, name: item.name)
              )
            }
          }
          
          completion(
            convertedListItems,
            nil
          )
          
        } catch let error {
          print(error)
          completion(nil, APIError.UnknownError)
        }
      case let .failure(error):
        print(error)
        completion(nil, handleAPIError(error))
      }
    }
  }
  
  func fetchPokemons(for id: Int, completion: @escaping ([PokemonItem]?, APIError?) -> Void) {
    provider.request(.ability(id: id)) { result in
      switch result {
      case let .success(response):
        do {
          let results = try JSONDecoder().decode(APIAbilityResponse.self, from: response.data)
          
          var convertedListItems = [PokemonItem]()
          
          for item in results.pokemon {
            if let id = PokeAPI.getIDFromURL(item.pokemon.url) {
              convertedListItems.append(
                PokemonItem(id: id, name: item.pokemon.name)
              )
            }
          }
          
          completion(
            convertedListItems,
            nil
          )
          
        } catch let error {
          print(error)
          completion(nil, APIError.UnknownError)
        }
      case let .failure(error):
        print(error)
        completion(nil, handleAPIError(error))
      }
    }
  }
  
  func dismissFetching() {
    Alamofire.Session.default.session.invalidateAndCancel()
  }
    
  // MARK: - Support structures
  
  private struct APIAbilitiesResponse: Codable {
    var results: [APIAbilitiesListItem]
  }
  
  private struct APIAbilitiesListItem: Codable {
    var name: String
    var url: String
  }
  
  private struct APIAbilityResponse: Codable {
    var pokemon: [APIAbilityPokemonItem]
  }
  
  private struct APIAbilityPokemonItem: Codable {
    var pokemon: APIAbilitiesListItem
  }
}
