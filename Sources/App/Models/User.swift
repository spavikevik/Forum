//
//  User.swift
//  
//
//  Created by Stefan Pavikevik on 2020/08/31.
//

import Fluent
import Vapor

enum UserGroup: Int, Codable {
    case admin, moderator, normal
}

final class User: Model, Content {
    static let schema = "user"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "group")
    var group: UserGroup
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String?
    
    @Timestamp(key: "registeredAt", on: .create)
    var registeredAt: Date?
        
    init() {}
    
    init(
        id: UUID? = nil,
        group: UserGroup,
        email: String,
        username: String,
        password: String?,
        registeredAt: Date?
    ) {
        self.id = id
        self.group = group
        self.email = email
        self.username = username
        self.password = password
        self.registeredAt = registeredAt
    }
    
    func hidePassword() -> User {
        User(
            id: self.id,
            group: self.group,
            email: self.email,
            username: self.username,
            password: nil,
            registeredAt: self.registeredAt
        )
    }
}

