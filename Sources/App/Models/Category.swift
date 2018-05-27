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
}
