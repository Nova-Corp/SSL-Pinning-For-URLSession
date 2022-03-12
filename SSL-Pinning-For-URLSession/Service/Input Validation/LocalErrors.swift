//
//  LocalErrors.swift
//  Login-Task-Using-SwiftUI
//
//  Created by ADMIN on 20/07/21.
//  Copyright © 2021 Success Resource Pte Ltd. All rights reserved.
//

import Foundation

import Foundation

enum LocalError: LocalizedError {
    case unknownError
    case serverError
    case parsingError

    var errorDescription: String? {
        switch self {
        case .unknownError: return "Unknown Error!"
        case .serverError: return "Server Error!"
        case .parsingError: return "Unable to parse the response"
        }
    }
}
