//
//  LocalErrors.swift
//  Login-Task-Using-SwiftUI
//
//  Created by ADMIN on 20/07/21.
//  Copyright © 2021 Success Resource Pte Ltd. All rights reserved.
//

import Foundation

import Foundation

enum ValidationError: LocalizedError {
    case unknownError
    case serverError

    var errorDescription: String? {
    switch self {
        case .unknownError: return "Unknown Error!"
        case .serverError: return "Server Error!"
        }
    }
}
