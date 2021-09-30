//
//  UsersViewModel.swift
//  SSL-Pinning-For-URLSession
//
//  Created by Mac on 30/09/21.
//

import UIKit

final class UsersViewModel {
    var users: [User]?
    var userListCompletion: ((Error?) -> Void)?
    func getUserList() {
        NetworkService.shared.makeRequestForUserList { result in
            switch result {
            case .success(let users):
                self.users = users
                self.userListCompletion?(nil)
            case .failure(let error):
                print("Error: \(error)")
                self.userListCompletion?(error)
            }
        }
    }
}
