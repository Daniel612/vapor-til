import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

//    /**
//     * 创建
//     * 注册新路由 api/acronyms 接受 POST 请求，然后返回 Future<Acronym>
//    */
//    router.post("api", "acronyms") { req -> Future<Acronym> in
//        // 解码请求的 JSON 为 Acronym 模型，解码完成时用 flatMap 提取 Future<Acronym>
//        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
//            // 用 Fluent 保存模型
//            return acronym.save(on: req)
//        }
//    }
    
//    /**
//     * 获取
//     * 在 api/acronyms 接收 GET 请求
//     */
//    router.get("api", "acronyms") { req -> Future<[Acronym]> in
//        return Acronym.query(on: req).all()
//    }
//    
//    /**
//     * 获取1个
//     * 在 api/acronyms/<ID> 接收 GET 请求
//     */
//    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
//        // 用参数函数从请求中提取 acronyms
//        return try req.parameters.next(Acronym.self)
//    }
//    
//    /**
//     * 更新1个
//     * 在 api/acronyms/<ID> 接收 PUT 请求
//     */
//    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
//        // 使用 flatMap 等待参数提取和内容解码。闭包的参数即来自数据库，也来自请求。
//        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self), { acronym, updatedAcronym in
//            acronym.short = updatedAcronym.short
//            acronym.long = updatedAcronym.long
//            
//            return acronym.save(on: req)
//        })
//    }
//    
//    /**
//     * 删除1个
//     * 在 api/acronyms/<ID> 接收 DELETE 请求
//     */
//    router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
//        // 用参数函数从请求中提取 acronyms
//        return try req.parameters.next(Acronym.self)    // 其实是先找到这个id的记录
//            .delete(on: req)                            // 删除
//            .transform(to: HTTPStatus.noContent)        // 把结果转换为状态码
//    }
//    
//    /**
//     * 搜索
//     * 在 api/acronyms/search 接收 GET 请求
//     */
//    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
//        // 从 URL 查询字符串获取搜索项，查询字符串可以与路径不匹配
//        guard let searchTerm = req.query[String.self, at: "term"] else {
//            throw Abort(.badRequest)
//        }
//        // 使用 filter 过滤出所有 acronyms，它们的 short 属性要匹配搜索项
//        return try Acronym.query(on: req).group(.or) { or in    // 设置过滤组的关系为 or
//            try or.filter(\.short == searchTerm) // 使用关键路径，编译器会在属性和搜索项上强制类型安全
//            try or.filter(\.long == searchTerm)
//        }.all()
//    }
//    
//    /**
//     * 获取查询的第一个结果
//     * 在 api/acronyms/first 接收 GET 请求
//     */
//    router.get("api", "acronyms", "first") { req -> Future<Acronym> in
//        return Acronym.query(on: req)
//            .first()
//            .map(to: Acronym.self) { acronym in     // 使用 map 函数去打开查询的结果
//                guard let acronym = acronym else {  // 确保存在
//                    throw Abort(.notFound)
//                }
//                return acronym
//        }
//    }
//    
//    /**
//     * 排序
//     * 在 api/acronyms/sorted 接收 GET 请求
//     */
//    router.get("api", "acronyms", "sorted") { req -> Future<[Acronym]> in
//        return try Acronym.query(on: req)
//            .sort(\.short, .ascending)
//            .all()
//    }
    
    let acronymsController = AcronymsController()
    // 确保控制器的路由注册了
    try router.register(collection: acronymsController)
    
    let usersController = UsersController()
    try router.register(collection: usersController)
    
    let categoriesController = CategoriesController()
    try router.register(collection: categoriesController)
    
    let websiteController = WebsiteController()
    try router.register(collection: websiteController)
}
