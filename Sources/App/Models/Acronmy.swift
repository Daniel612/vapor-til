import Vapor
import FluentSQLite

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    init(short: String, long: String) {
        self.short = short
        self.long = long
    }
}
// 告诉 Fluent 这个模型所使用的数据库
extension Acronym: SQLiteModel {}
// 让 Fluent 来创建数据库模式
extension Acronym: Migration {}
// 让模型能够转换成其他格式
extension Acronym: Content {}
