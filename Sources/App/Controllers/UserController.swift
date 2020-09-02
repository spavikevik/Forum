//
//  UserController.swift
//  
//
//  Created by Stefan Pavikevik on 2020/08/31.
//

import Fluent
import Vapor

struct GetUser: Content {
    var id: UUID
    var username: String
    var group: UserGroup
    var registeredAt: Date?
}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post(use: create)

        users.group(":id") { user in
            user.get(use: show)
            user.put(use: update)
            user.delete(use: delete)
        }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[GetUser]> {
        return User.query(on: req.db).all().flatMapThrowing { users in
            try users.map { user in
                try GetUser(
                    id: user.requireID(),
                    username: user.username,
                    group: user.group,
                    registeredAt: user.registeredAt
                )
            }
        }
    }
    
    func create(req: Request) throws -> EventLoopFuture<User> {
        let user: User = try req
            .content
            .decode(User.self)
            .setPassword(password: req.parameters.get("password").map { try req.password.hash($0) })
        return user
            .create(on: req.db)
            .transform(to: user)
    }

    func show(req: Request) throws -> EventLoopFuture<User> {
        guard let id = req.parameters.get("id") else {
            throw Abort(.internalServerError)
        }
        
        return User
            .find(UUID(id), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func update(req: Request) throws -> EventLoopFuture<User> {
        guard let id = req.parameters.get("id") else {
            throw Abort(.internalServerError)
        }
        
        let updatedUser: User = try req.content.decode(User.self)
        
        return User
            .find(UUID(id), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.username = updatedUser.username
                user.email = updatedUser.email
                user.password = updatedUser.password
                user.group = updatedUser.group
                
                return user.save(on: req.db)
                    .transform(to: user)
        }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id") else {
            throw Abort(.internalServerError)
        }
        
        return User
            .find(UUID(id), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
