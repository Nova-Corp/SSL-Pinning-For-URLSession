//
//  NetworkService.swift
//  SSL-Pinning-For-URLSession
//
//  Created by Mac on 31/10/21.
//

import Foundation

// MARK:- Public API Service
class NetworkService: NetworkServiceHandler {
    static let shared = NetworkService()
    private override init() {}
    // MARK:- Get User List
    func makeRequestForUserList(completion: @escaping (Result<[User], Error>) -> Void) {
        request(route: .user, type: [User].self,completion: completion)
    }
    
    // MARK:- Get User's Blog Post Details
    func makeRequestForUserBlogPost(parameter: [String: Any]?, completion: @escaping (Result<PostDetail, Error>) -> Void) {
        request(route: .posts, method: .POST, parameter: parameter, type: PostDetail.self,completion: completion)
    }
}

