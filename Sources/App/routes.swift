import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    /**
     注册新路由 api/acronyms 接受 POST 请求，然后返回 Future<Acronym>
    */
    router.post("api", "acronyms") { req -> Future<Acronym> in
        // 解码请求的 JSON 为 Acronym 模型，解码完成时用 flatMap 提取 Future<Acronym>
        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
            // 用 Fluent 保存模型
            return acronym.save(on: req)
        }
    }
}
