import FluentMySQL
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())   // 允许应用通过 Fluent 与 MySQL 交互
    try services.register(LeafProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

//    /// Register the configured MySQL database to the database config.
//    var databases = DatabasesConfig()
//
//    // 使用 Docker 中 mysql 镜像相同的配置
//    let databaseConfig = MySQLDatabaseConfig(
//        hostname: "localhost",
//        port: 3306,
//        username: "vapor",
//        password: "password",
//        database: "vapor")
//    let database = MySQLDatabase(config: databaseConfig)
//    databases.add(database: database, as: .mysql)
//    services.register(databases)
    

    var databases = DatabasesConfig()
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName: String
    let databasePort: Int
    if (env == .testing) {
        databaseName = "vapor-test"
        if let testPort = Environment.get("DATABASE_PORT") {
            databasePort = Int(testPort) ?? 5433
        } else {
            databasePort = 5433
        }
    } else {
        databaseName = Environment.get("DATABASE_DB") ?? "vapor"
        databasePort = 3306
    }
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    let databaseConfig = MySQLDatabaseConfig(
        hostname: hostname,
        port: databasePort, // 测试使用不同的端口
        username: username,
        password: password,
        database: databaseName)
    let database = MySQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    // 保证创建表的顺序正确
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Acronym.self, database: .mysql)
    migrations.add(model: Category.self, database: .mysql)
    migrations.add(model: AcronymCategoryPivot.self, database: .mysql)
    services.register(migrations)

    /// 恢复所有迁移
    var commandConfig = CommandConfig.default()
    commandConfig.use(RevertCommand.self, as: "revert")
    services.register(commandConfig)
    
    // 告诉 Vapor 使用 LeafRenderer，当请求一个 ViewRenderer 类型时
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
}
