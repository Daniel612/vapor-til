import Vapor
import FluentMySQL

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    var userID: User.ID
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}
// 告诉 Fluent 这个模型所使用的数据库
extension Acronym: MySQLModel {}
// 让模型能够转换成其他格式
extension Acronym: Content {}
// 对于参数的强大的类型安全
extension Acronym: Parameter {}

// 获取 acronyms 的父模型
extension Acronym {
    // 返回 Fluent 的通用父类型
    var user: Parent<Acronym, User> {
        // 使用了 acronym 引用 user 的关键路径
        return parent(\.userID)
    }
    // 获取一个 acronyms 的所有 categories
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        return siblings()
    }
}

// 让 Fluent 来创建数据库模式
extension Acronym: Migration {
    // 重写默认的执行方案
    static func prepare(on connnection: MySQLConnection) -> Future<Void> {
        // 在数据库中创建 Acronym 表
        return Database.create(self, on: connnection) { builder in
            // 将所有字段添加到数据库中
            try addProperties(to: builder)
            // 设置参照完整性
            try builder.addReference(from: \.userID, to: \User.id)
        }
    }
}
