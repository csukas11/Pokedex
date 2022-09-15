//
//  PokeAPI.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import Moya

enum PokeAPI {
  static var imageURL: String {
    return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"
  }
  
  case pokemons
  case pokemon(id: Int)
  case types
  case type(id: Int)
  case abilities
  case ability(id: Int)
  case moves
  case move(id: Int)
  
  static func getIDFromURL(_ url: String) -> Int? {
    var idArray = url.components(separatedBy: CharacterSet.decimalDigits.inverted)
    for _ in 0..<idArray.count {
      if let id = Int(idArray.removeLast()) {
        return id
      }
    }
    return nil
  }
}

extension PokeAPI: TargetType {
  var baseURL: URL {
    var url_str = ""
    
    switch self {
    case .pokemons: fallthrough
    case .pokemon(_): fallthrough
    case .types: fallthrough
    case .type(_): fallthrough
    case .abilities: fallthrough
    case .ability(_): fallthrough
    case .moves:  fallthrough
    case .move(_): url_str = "https://pokeapi.co/api/v2"
    }
    
    guard let url = URL(string: url_str)  else {
      fatalError("baseURL cannot be configured")
    }
    return url
  }
  
  var path: String {
    switch self {
    case .pokemons: return "/pokemon"
    case .pokemon(let id): return "/pokemon/\(id)"
    case .types: return "/type"
    case .type(let id): return "/type/\(id)"
    case .abilities: return "/ability"
    case .ability(let id): return "/ability/\(id)"
    case .moves: return "/move"
    case .move(let id): return "/move/\(id)"
    }
  }
  
  var method: Method {
    switch self {
    case .pokemons: fallthrough
    case .pokemon(_): fallthrough
    case .types: fallthrough
    case .type(_): fallthrough
    case .abilities: fallthrough
    case .ability(_): fallthrough
    case .moves:  fallthrough
    case .move(_): return .get
    }
  }
  
  var sampleData: Data {
    return Data()
  }
  
  var task: Task {
    switch self {
    case .pokemons: fallthrough
    case .types: fallthrough
    case .abilities: fallthrough
    case .moves:
      let params: Dictionary<String, String> = [
        "limit": "999999",
        "offset": "0"
      ]
      
      return .requestParameters(
        parameters: params,
        encoding: URLEncoding.default
      )
    case .pokemon(_): fallthrough
    case .type(_): fallthrough
    case .ability(_): fallthrough
    case .move(_):
      return .requestPlain
    }
  }
  
  var headers: [String : String]? {
    return ["Content-Type": "application/json"]
  }
  
  public var validationType: ValidationType {
    return .successCodes
  }
}

// MARK: - HandleAPIError
func handleAPIError(_ error: MoyaError) -> APIError {
  switch error {
  case .statusCode(let response):
    switch response.statusCode {
    default:
      return APIError.UnknownError
    }
    
  case .underlying(let nsError as NSError, _):
    switch nsError.code {
    case NSURLErrorTimedOut:
      return APIError.ResponseTimeOut
    case NSURLErrorNotConnectedToInternet:
      return APIError.NoInternetConnection
    default:
      return APIError.UnknownError
    }
  default:
    return APIError.UnknownError
  }
}

