//
//  APIError.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

enum APIError {
  case UnknownError
  case NoInternetConnection
  case ResponseTimeOut
  
  var errorMsg: String {
      switch self {
      case .NoInternetConnection:
        return "There is no internet connection!"
      
      case .ResponseTimeOut:
        return "Network connection time out."
      case .UnknownError:
        return ""
      }
   }
}
