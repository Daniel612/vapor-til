import Foundation
import Vapor
import FluentMySQL

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    
    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}

// 告诉 Fluent 模型使用了 MySQL UUID
extension User: MySQLUUIDModel {}
extension User: Content {}
extension User: Migration {}
extension User: Parameter {}

extension User {
    var acronyms: Children<User, Acronym> {
        // 还是用 acronym 引用 user 关键路径来找出所有的子对象
        return children(\.userID)
    }
}
