//
//  MovesFetcher.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import Moya
import Alamofire
import Kingfisher

class MovesFetcher {
  var provider = MoyaProvider<PokeAPI>(callbackQueue: DispatchQueue.global(qos: .userInitiated)) //MoyaProvider<PokeAPI>(plugins: [NetworkLoggerPlugin()])
  
  func fetch(completion: @escaping ([Move]?, APIError?) -> Void) {
    provider.request(.moves) { result in
      switch result {
      case let .success(response):
        do {
          let results = try JSONDecoder().decode(APIMovesResponse.self, from: response.data)
          
          var convertedListItems = [Move]()
          
          for item in results.results {
            if let id = PokeAPI.getIDFromURL(item.url) {
              convertedListItems.append(
                Move(id: id, name: item.name)
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
    provider.request(.move(id: id)) { result in
      switch result {
      case let .success(response):
        do {
          let results = try JSONDecoder().decode(APIMoveResponse.self, from: response.data)
          
          var convertedListItems = [PokemonItem]()
          
          for item in results.learned_by_pokemon {
            if let id = PokeAPI.getIDFromURL(item.url) {
              convertedListItems.append(
                PokemonItem(id: id, name: item.name)
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
  
  private struct APIMovesResponse: Codable {
    var results: [APIMovesListItem]
  }
  
  private struct APIMovesListItem: Codable {
    var name: String
    var url: String
  }
  
  private struct APIMoveResponse: Codable {
    var learned_by_pokemon: [APIMovesListItem]
  }
}
