//
//  UserDetails+Protocol.swift
//  SSL-Pinning-For-URLSession
//
//  Created by Mac on 12/03/22.
//

import Foundation

protocol UserDetailsProtocol: NetworkServiceHandler {
    func makeRequestForUserList(completion: @escaping (Result<[User], Error>) -> Void)
    func makeRequestForUserBlogPost(parameter: [String: Any]?, completion: @escaping (Result<PostDetail, Error>) -> Void)
}
