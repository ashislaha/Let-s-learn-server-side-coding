//
//  Model.swift
//  UserDatabase
//
//  Created by Ashis Laha on 5/20/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation

struct User: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let address: String?
}

