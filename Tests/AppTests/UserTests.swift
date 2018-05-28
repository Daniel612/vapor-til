@testable import App
import Vapor
import XCTest
import FluentMySQL

final class UserTests: XCTestCase {
    
//    func testUsersCanBeRetrivedFromAPI() throws {
//        // MARK: - 重置数据库
//        // 设置应用要执行的参数
//        let revertEnviromentArgs = ["vapor", "revert", "--all", "-y"]
//
//        var revertConfig = Config.default()
//        var revertServices = Services.default()
//        var revertEnv = Environment.testing
//
//        revertEnv.arguments = revertEnviromentArgs
//        try App.configure(&revertConfig, &revertEnv, &revertServices)
//        let revertApp = try Application(config: revertConfig, environment: revertEnv, services: revertServices)
//        try App.boot(revertApp)
//        // 执行恢复命令
//        try revertApp.asyncRun().wait()
//
//        // 定义一些要测试的期望值
//        let expectedName = "Alice"
//        let expectedUserName = "alice"
//        // 创建一个应用但不是运行它，环境是测试
//        var config = Config.default()
//        var services = Services.default()
//        var env = Environment.testing
//        try App.configure(&config, &env, &services)
//        let app = try Application(config: config, environment: env, services: services)
//        try App.boot(app)
//        // 创建连接执行数据库操作
//        // 因为没有运行应用，所以在整个过程中要使用 wait 等待返回 future
//        let conn = try app.newConnection(to: .mysql).wait()
//        // 创建一对用户并保存到数据库
//        let user = User(name: expectedName, username: expectedUserName)
//        let savedUser = try user.save(on: conn).wait()
//        _ = try User(name: "Luke", username: "lukes").save(on: conn).wait()
//        // 创建一个应答器类型来回应你的请求
//        let responder = try app.make(Responder.self)
//        let request = HTTPRequest(method: .GET, url: URL(string: "/api/users")!)
//        // 这里有 Worker 打包 HTTPRequest 成请求
//        let wrappedRequest = Request(http: request, using: app)
//        // 发送请求和获得回应
//        let response = try responder.respond(to: wrappedRequest).wait()
//        // 解码回应的数据到一组用户中
//        let data = response.http.body.data
//        let users = try JSONDecoder().decode([User].self, from: data!)
//        // 测试相应的值是否相等
//        XCTAssertEqual(users.count, 2)
//        XCTAssertEqual(users[0].name, expectedName)
//        XCTAssertEqual(users[0].username, expectedUserName)
//        XCTAssertEqual(users[0].id, savedUser.id)
//        // 测试完成之后关闭连接
//        conn.close()
//    }
    
    let usersName = "Alice"
    let usersUserName = "alicea"
    let usersURI = "/api/users/"
    var app: Application!
    var conn: MySQLConnection!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .mysql).wait()
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testUsersCanBeRetrievedFromAPI() throws {
        let user = try User.create(name: usersName,
                                   username: usersUserName,
                                   on: conn)
        _ = try User.create(on: conn)
        let users = try app.getResponse(to: usersURI,
                                        decodeTo: [User].self)
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].username, usersUserName)
        XCTAssertEqual(users[0].id, user.id)
    }
    
    // 保存用户
    func testUserCanBeSavedWithAPI() throws {
        // 用已知值创建一个用户对象
        let user = User(name: usersName, username: usersUserName)
        // 用新的请求方法返回对象
        let receivedUser = try app.getResponse(to: usersURI, method: .POST, headers: ["Content-type": "application/json"], data: user, decodeTo: User.self)
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUserName)
        XCTAssertNotNil(receivedUser.id)
        
        let users = try app.getResponse(to: usersURI,
                                        decodeTo: [User].self)
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].username, usersUserName)
        XCTAssertEqual(users[0].id, receivedUser.id)
    }
    
    // 获得单个用户
    func testGettingASingleUserFromTheAPI() throws {
        let user = try User.create(name: usersName,
                                   username: usersUserName,
                                   on: conn)
        let receivedUser = try app.getResponse(to: "\(usersURI)\(user.id!)", decodeTo: User.self)
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUserName)
        XCTAssertEqual(receivedUser.id, user.id)
    }
    
    // 获得用户的 acronyms
    func testGettingAUsersAcronymsFromTheAPI() throws {
        let user = try User.create(on: conn)
        let acronymShort = "OMG"
        let acronymLong = "Oh My God"
        let acronym1 = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: conn)
        _ = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: conn)
        
        let acronyms = try app.getResponse(to: "\(usersURI)\(user.id!)/acronyms", decodeTo: [Acronym].self)
        
        XCTAssertEqual(acronyms.count, 2)
        XCTAssertEqual(acronyms[0].id, acronym1.id)
        XCTAssertEqual(acronyms[0].short, acronymShort)
        XCTAssertEqual(acronyms[0].long, acronymLong)
    }
    
    static let allTests = [
        ("testUsersCanBeRetrievedFromAPI",
         testUsersCanBeRetrievedFromAPI),
        ("testUserCanBeSavedWithAPI", testUserCanBeSavedWithAPI),
        ("testGettingASingleUserFromTheAPI",
         testGettingASingleUserFromTheAPI),
        ("testGettingAUsersAcronymsFromTheAPI",
         testGettingAUsersAcronymsFromTheAPI)
    ]
}
