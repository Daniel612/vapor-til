import FluentMySQL
import Foundation

final class AcronymCategoryPivot: MySQLUUIDPivot {
    // 需要导入 Foundation
    var id: UUID?
    // 两个 id 属性保持了之间的关系
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    // Pivot 必须要定别名的两个属性
    typealias Left = Acronym
    typealias Right = Category
    // 告诉 Fluent 两边的 id 属性的关键路径
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID
    
    init(_ acronymID: Acronym.ID, _ categoryID: Category.ID) {
        self.acronymID = acronymID
        self.categoryID = categoryID
    }
}

// 这个枢纽只是为了说明 acronym 和 category 是兄弟关系，不是 MySQLModel，也不需要单独查询和更新。
extension AcronymCategoryPivot: Migration {
    // 重写默认的执行方案
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        // 创建 AcronymCategoryPivot 表
        return Database.create(self, on: connection) { builder in
            // 添加所有字段
            try addProperties(to: builder)
            // 外键约束
            try builder.addReference(from: \.acronymID, to: \Acronym.id)
            // 外键约束
            try builder.addReference(from: \.categoryID, to: \Category.id)
        }
    }
}
