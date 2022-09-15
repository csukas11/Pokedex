//
//  PokemonsFetcher.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import Moya
import Alamofire
import Kingfisher

class PokemonsFetcher {
  var provider = MoyaProvider<PokeAPI>(callbackQueue: DispatchQueue.global(qos: .userInitiated)) //MoyaProvider<PokeAPI>(plugins: [NetworkLoggerPlugin()])
  
  func fetch(completion: @escaping ([PokemonItem]?, APIError?) -> Void) {
    provider.request(.pokemons) { result in
      switch result {
      case let .success(response):
        do {
          let results = try JSONDecoder().decode(APIPokemonsResponse.self, from: response.data)
          
          var convertedListItems = [PokemonItem]()
          
          for item in results.results {
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
  
  func fetchPokemon(_ id: Int, completion: @escaping (Pokemon?, APIError?) -> Void) {
    provider.request(.pokemon(id: id)) { result in
      switch result {
      case let .success(response):
        do {
          let res = try JSONDecoder().decode(APIPokemonResponse.self, from: response.data)
          
          var pokemon = Pokemon()
          
          pokemon.id = res.id
          pokemon.name = res.name
          if let bd_img = res.sprites.back_default {
            pokemon.imageURLs.updateValue(bd_img, forKey: "back_male")
          }
          if let bf_img = res.sprites.back_female {
            pokemon.imageURLs.updateValue(bf_img, forKey: "back_female")
          }
          if let fd_img = res.sprites.front_default {
            pokemon.imageURLs.updateValue(fd_img, forKey: "front_male")
          }
          if let ff_img = res.sprites.front_female {
            pokemon.imageURLs.updateValue(ff_img, forKey: "front_female")
          }
          if res.types.count > 0 {
            pokemon.type = res.types[0].type.name
          }
          for stat in res.stats {
            switch stat.stat.name {
            case "hp":
              pokemon.hp = stat.base_stat
            case "defense":
              pokemon.def = stat.base_stat
            case "attack":
              pokemon.atk = stat.base_stat
            case "speed":
              pokemon.sp = stat.base_stat
            default: break
            }
          }
          
          completion(
            pokemon,
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
  
  private struct APIPokemonsResponse: Codable {
    var results: [APIPokemonsListItem]
  }
  
  private struct APIPokemonsListItem: Codable {
    var name: String
    var url: String
  }
  
  private struct APIPokemonResponse: Codable {
    var id: Int
    var name: String
    var sprites: APIPokemonSprites
    var types: [APIPokemonTypesList]
    var stats: [APIPokemonStatsListItem]
  }
  
  private struct APIPokemonSprites: Codable {
    var back_default: String?
    var back_female: String?
    var front_default: String?
    var front_female: String?
  }
  
  private struct APIPokemonTypesList: Codable {
    var type: APIPokemonsListItem
  }
  
  private struct APIPokemonStatsListItem: Codable {
    var base_stat: Int
    var stat: APIPokemonsListItem
  }
}
