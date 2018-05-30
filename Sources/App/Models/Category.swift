import Vapor
import FluentMySQL

final class Category: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Category: MySQLModel {}
extension Category: Content {}
extension Category: Migration {}
extension Category: Parameter {}

// 兄弟关系
extension Category {
    var acronyms: Siblings<Category, Acronym, AcronymCategoryPivot> {
        return siblings()
    }
    
    static func addCategory(_ name: String, to acronym: Acronym, on req: Request) throws -> Future<Void> {
        // 用提供的名字查询类别
        return try Category.query(on: req)
            .filter(\.name == name)
            .first()
            .flatMap(to: Void.self) { foundCategory in
            if let existingCategory = foundCategory {
                // 如果存在，则创建枢纽
                let pivot = try AcronymCategoryPivot(acronym.requireID(), existingCategory.requireID())
                return pivot.save(on: req).transform(to: ())
            } else {
                // 不存在就创建新的
                let category = Category(name: name)
                // 保存到数据库中
                return category.save(on: req).flatMap(to: Void.self) { savedCategory in
                    // 用返回值创建新的枢纽
                    let pivot = try AcronymCategoryPivot(acronym.requireID(), savedCategory.requireID())
                    // 保存新枢纽并把结果转为空
                    return pivot.save(on: req).transform(to: ())
                }
            }
        }
    }
}
