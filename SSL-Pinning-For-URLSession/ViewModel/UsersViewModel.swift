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
    var networkManager: UserDetailsProtocol = UserDetailsNetworkService()
    // Blog Post
    var details: PostDetail?
    var blogPostDetailsCompletion: ((Error?) -> Void)?
    func callAsFunction() {
        networkManager.makeRequestForUserList { result in
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
    
    func callAsFunction(for params: [String: Any]) {
        networkManager.makeRequestForUserBlogPost(parameter: params) { result in
            switch result {
            case .success(let details):
                self.details = details
                self.blogPostDetailsCompletion?(nil)
            case .failure(let error):
                self.blogPostDetailsCompletion?(error)
            }
        }
    }
}
