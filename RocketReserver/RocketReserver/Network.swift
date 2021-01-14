//
//  Network.swift
//  RocketReserver
//
//  Created by Archna Sukhija on 10/01/21.
//

import Foundation
import Apollo

class Network {
  static let shared = Network()
    
  private(set) lazy var apollo = ApolloClient(url: URL(string: "https://apollo-fullstack-tutorial.herokuapp.com")!)
}
