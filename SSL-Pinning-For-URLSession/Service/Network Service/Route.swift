//
//  Route.swift
//  Network-Call-Practice
//
//  Created by ADMIN on 19/06/21.
//  Copyright © 2021 Success Resource Pte Ltd. All rights reserved.
//

import Foundation

enum Route {
    static let baseURL = "https://jsonplaceholder.typicode.com/"
    case user
    case defaultImageAddress
    var description: String {
        switch self {
        case .user:
            return "users"
        case .defaultImageAddress:
            return "https://i.pinimg.com/originals/4e/24/f5/4e24f523182e09376bfe8424d556610a.png"
        }
    }
}
