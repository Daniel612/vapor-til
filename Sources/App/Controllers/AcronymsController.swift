import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let acronymRoutes = router.grouped("api", "acronyms")
        acronymRoutes.get(use: getAllHandler)
        acronymRoutes.post(Acronym.self, use: createHandler)
        acronymRoutes.get(Acronym.parameter, use: getHandler)
        acronymRoutes.put(Acronym.parameter, use: updateHandler)
        acronymRoutes.delete(Acronym.parameter, use: deleteHandler)
        acronymRoutes.get("search", use: searchHandler)
        acronymRoutes.get("first", use: getFirstHandler)
        acronymRoutes.get("sorted", use: sortedHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
//        return try req.content                          // 请求的 JSON 数据
//            .decode(Acronym.self)                       // 解析为对应的模型
//            .flatMap(to: Acronym.self) { acronym in     // flatmap 提取参数
//                return acronym.save(on: req)            // 保存到数据库并返回 Future
//        }
        return acronym.save(on: req)
    }
    
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        // 注意参数是按顺序获取的
        return try req.parameters.next(Acronym.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),   // 根据 ID 从数据库找到原数据
                           req.content.decode(Acronym.self)) {
                            acronym, updatedAcronym in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
            .next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at:"term"] else {
            throw Abort(.badRequest)
        }
        return try Acronym.query(on: req).group(.or) { or in
            try or.filter(\.short == searchTerm)
            try or.filter(\.long == searchTerm)
        }.all()
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req).first().map(to: Acronym.self) { acronym in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            return acronym
        }
    }
    
    func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try Acronym.query(on: req)
            .sort(\.short, .ascending)
            .all()
    }
}