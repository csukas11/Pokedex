//
//  TypesFetcher.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import Moya
import Alamofire
import Kingfisher

class TypesFetcher {
  var provider = MoyaProvider<PokeAPI>(callbackQueue: DispatchQueue.global(qos: .userInitiated)) //MoyaProvider<PokeAPI>(plugins: [NetworkLoggerPlugin()])
  
  func fetch(completion: @escaping ([Type]?, APIError?) -> Void) {
    provider.request(.types) { result in
      switch result {
      case let .success(response):
        do {
          let results = try JSONDecoder().decode(APITypesResponse.self, from: response.data)
          
          var convertedListItems = [Type]()
          
          for item in results.results {
            if let id = PokeAPI.getIDFromURL(item.url) {
              convertedListItems.append(
                Type(id: id, name: item.name)
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
    provider.request(.type(id: id)) { result in
      switch result {
      case let .success(response):
        do {
          let results = try JSONDecoder().decode(APITypeResponse.self, from: response.data)
          
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
  
  private struct APITypesResponse: Codable {
    var results: [APITypesListItem]
  }
  
  private struct APITypesListItem: Codable {
    var name: String
    var url: String
  }
  
  private struct APITypeResponse: Codable {
    var pokemon: [APITypePokemonItem]
  }
  
  private struct APITypePokemonItem: Codable {
    var pokemon: APITypesListItem
  }
}
