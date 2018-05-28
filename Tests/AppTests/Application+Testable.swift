import Vapor
import App
import FluentMySQL

extension Application {
    // 创建一个可测试应用对象
    static func testable(envArgs: [String]? = nil) throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        
        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }
        
        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        
        try App.boot(app)
        return app
    }
    
    // 使用上面的方法创建应用然后运行 revert 命令，这可以在每次测试时很方便地重置数据库
    static func reset() throws {
        let revertEnvironment = ["vapor", "revert", "--all", "-y"]
        try Application.testable(envArgs: revertEnvironment).asyncRun().wait()
    }
    
    // 定义一个方法发送请求和返回响应
    func sendRequest(to path: String,
                     method: HTTPMethod,
                     headers: HTTPHeaders = .init(),
                     body: HTTPBody = .init()) throws -> Response {
        let responder = try self.make(Responder.self)
        let request = HTTPRequest(method: method, url: URL(string: path)!, headers: headers, body: body)
        let wrappedRequest = Request(http: request, using: self)
        return try responder.respond(to: wrappedRequest).wait()
    }
    // 发送有主体的请求，但忽略响应
    func sendRequest<T>(to path: String,
                        method: HTTPMethod,
                        headers: HTTPHeaders,
                        data: T) throws where T: Encodable {
        let body = try HTTPBody(data: JSONEncoder().encode(data))
        _ = try self.sendRequest(to: path, method: method, headers: headers, body: body)
    }
    
    // 定义一个泛型方法返回可解码类型
    func getResponse<T>(to path: String,
                        method: HTTPMethod = .GET,
                        headers: HTTPHeaders = .init(),
                        body: HTTPBody = .init(),
                        decodeTo type: T.Type) throws -> T where T: Decodable {
        // 使用上面的方法获得响应
        let response = try self.sendRequest(to: path, method: method, headers: headers, body: body)
        // 解码响应体为泛型并返回结果
        return try JSONDecoder().decode(type, from: response.http.body.data!)
    }
    
    // 用编码的模型作为主体发送请求
    func getResponse<T, U>(to path: String,
                           method: HTTPMethod = .GET,
                           headers: HTTPHeaders = .init(),
                           data: U,
                           decodeTo type: T.Type) throws -> T where T: Decodable, U: Encodable {
        let body = try HTTPBody(data: JSONEncoder().encode(data))
        return try self.getResponse(to: path,
                                    method: method,
                                    headers: headers,
                                    body: body,
                                    decodeTo: type)
    }
}
