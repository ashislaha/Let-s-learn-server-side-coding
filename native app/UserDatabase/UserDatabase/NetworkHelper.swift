//
//  NetworkHelper.swift
//  UserDatabase
//
//  Created by Ashis Laha on 5/20/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case InvalidURL
    case InvalidJSON
}

enum PostOperations {
    case add
    case update
    case delete
}

struct Constants {
    static let endPoint = "https://explore-world.herokuapp.com"  //"http://localhost:3000"
}

class NetworkHandler {
    
    // get all users (GET)
    class func getUsers(completionHandler: @escaping (([User])->())) throws {
        
        guard let url = URL(string: Constants.endPoint + "/users") else { throw NetworkError.InvalidURL }
        let session = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else { return }
            guard let users = try? JSONDecoder().decode([User].self, from: data) else { return }
            DispatchQueue.main.async {
                completionHandler(users)
            }
        }
        session.resume()
    }
    
    // get a user by user_id (GET)
    class func getUsersById(_ id: Int, completionHandler: @escaping ((User)->())) throws {
        
        guard let url = URL(string: Constants.endPoint + "/user/\(id)") else { throw NetworkError.InvalidURL }
        let session = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else { return }
            guard let users = try? JSONDecoder().decode([User].self, from: data) else { return }
            DispatchQueue.main.async {
                if let firstUser = users.first {
                    completionHandler(firstUser)
                }
            }
        }
        session.resume()
    }
    
    // POST call: add, update and delete
    class func postCall(operation:PostOperations, params: [String: Any], completionHandler: @escaping (([String: Any])->())) throws {
        var urlString = Constants.endPoint
        switch operation {
        case .add: urlString += "/user_create"
        case .update: urlString += "/update_user"
        case .delete: urlString += "/delete_user"
        let userId = params["id"] as? Int ?? -1
        urlString += "/\(userId)"
        }
        guard let url = URL(string: urlString) else { throw NetworkError.InvalidURL }
        
        let session = URLSession(configuration: .default)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        if operation != .delete {
            guard let body = NetworkHandler.dataFromDict(params) else { return }
            urlRequest.httpBody = body
        }
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        session.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { return }
            if error == nil {
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                    if let dict = json as? [String: Any] {
                        completionHandler(dict)
                    }
                }
            } else { // some error
                print(error?.localizedDescription ?? "")
                completionHandler([:])
            }
            }.resume()
    }
    
    private class func dataFromDict(_ dict: [String: Any]) -> Data? {
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        return data ?? nil
    }
}

extension NetworkHandler {
    private class func getString(_ dict: [String: Any]) -> String {
        var params = ""
        for (key, value) in dict {
            params += "\(key)" + "=" + "\(value)" + "&"
        }
        let truncated = String(params.dropLast()) // remove last &
        return truncated
    }
}
