import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user")
            .id()
            .field("group", .int, .required)
            .field("email", .string, .required)
            .field("username", .string, .required)
            .field("password", .string, .required)
            .field("registeredAt", .date, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user").delete()
    }
}
