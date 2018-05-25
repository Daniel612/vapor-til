import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.post(User.self, use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getHandler)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User> {
        // 如果 save 操作之前没有其他的操作，可以直接在 post 方法中添加模型类型，它会自动完成解码。
        return user.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        // 使用 Fluent 的查询返回所有用户
        return User.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User> {
        // 通过请求参数返回特定用户
        return try req.parameters.next(User.self)
    }
}
