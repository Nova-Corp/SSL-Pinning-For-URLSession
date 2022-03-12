//
//  NetworkServiceHandler.swift
//  Network-Call-Practice
//
//  Created by ADMIN on 19/06/21.
//  Copyright © 2021 Success Resource Pte Ltd. All rights reserved.
//

import Foundation
import CommonCrypto

class NetworkServiceHandler: NSObject {
    // Refer: https://www.ssllabs.com/ssltest/
    private var sslPinning: SSLPinning = .none
    func request<T: Codable>(route: Route,
                                     method: HTTPMethod = .GET,
                                     parameter: [String: Any]? = nil,
                                     type: T.Type,
                                     completion: @escaping (Result<T, Error>) -> Void) {
        let request = createRequest(route: route, method: method, parameter: parameter)
        let session = sslPinning == .none ? URLSession.shared : URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                // let responseString = String(data: data, encoding: .utf8) ?? "Unable to convert as string."
                // print("Response is:-------> \(responseString)")
                guard let result = try? JSONDecoder().decode(type, from: data) else{
                    // print("Error is:-------> \(ValidationError.parsingError.localizedDescription)")
                    return completion(.failure(LocalError.parsingError))
                }
                completion(.success(result))
            } else if let error = error {
                // print("Error is:-------> \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                completion(.failure(LocalError.unknownError))
            }
        }
        task.resume()
    }
    /// This function helps to create URLRequest
    /// - Parameters:
    ///   - route: Backend resource path
    ///   - method: Type of HTTP Request
    ///   - parameter: Need to pass to backend
    /// - Returns: It returns URLRequest
    private func createRequest(route: Route,
                               method: HTTPMethod = .GET,
                               parameter: [String: Any]? = nil) -> URLRequest {
        let urlString = Route.baseURL + route.description
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = method.rawValue
        
        if let params = parameter {
            switch method {
            case .GET:
                var urlComponent = URLComponents(string: urlString)
                urlComponent?.queryItems = params.map {URLQueryItem(name: $0, value: "\($1)")}
                
                urlRequest.url = urlComponent?.url
            case .POST, .DELETE, .PATCH:
                let bodyData = try? JSONSerialization.data(withJSONObject: params,
                                                           options: [])
                urlRequest.httpBody = bodyData
            }
        }
        return urlRequest
    }
}

extension NetworkServiceHandler: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        // MARK:- Index Value
        // 1. Leaf          - 0
        // 2. Intermediate  - 1
        // 3. Root          - 2
        guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, 2) else { return }
        // SSL Policies for domain name check
        let policy = NSMutableArray()
        policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        SecTrustSetPolicies(serverTrust, policy)
        
        // evaluate server certifiacte
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
        
        switch sslPinning {
        case .certificatePinning(let name, let type):
            // Local and Remote certificate Data
            let remoteCertificateData: NSData =  SecCertificateCopyData(certificate)
            // Local Certificate
            guard let pathToCertificate = Bundle.main.path(forResource: name, ofType: type.rawValue) else { return }
            guard let localCertificateData: NSData = NSData(contentsOfFile: pathToCertificate) else { return }
            
            // Compare certificates
            if(isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data)){
                let credential: URLCredential =  URLCredential(trust:serverTrust)
                print("Certificate pinning is successfully completed")
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        case .publicKeyPinning(let key):
            guard let serverPublicKey = SecCertificateCopyKey(certificate) else { return }
            guard let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil ) else { return }
            let data: Data = serverPublicKeyData as Data
            // Server Hash key
            let serverHashKey = sha256(data: data)
            // Local Hash Key
            if isServerTrusted && (serverHashKey == key) {
                // Success! This is our server
                print("Public key pinning is successfully completed")
                completionHandler(.useCredential, URLCredential(trust:serverTrust))
                return
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        case .none: break
        }
    }
    
    private func sha256(data : Data) -> String {
        // Use the following headers
        // MARK:- (Intermediate and Leaf) EC 256 bits / SHA256withRSA & SHA256withECDSA
        // 0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01,
        // 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00
        
        // MARK:- (Root Certificate) RSA 2048 bits (e 65537) / SHA1withRSA
        // 0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        // 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
        let headerForEncryption: [UInt8] = [
             0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01,
             0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00
        ]
        
        var keyWithHeader = Data(headerForEncryption)
        keyWithHeader.append(data)
        
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = keyWithHeader.withUnsafeBytes {
            CC_SHA256($0.baseAddress, CC_LONG(keyWithHeader.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
    
    enum SSLPinning: Equatable {
        case certificatePinning(name: String, type: CertificateType)
        case publicKeyPinning(key: String)
        case none
        
        enum CertificateType: String {
            case cer
            case der
        }
    }
}
