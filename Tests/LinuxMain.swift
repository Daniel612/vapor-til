//
//  LinuxMain.swift
//  App
//
//  Created by daniel on 2018/5/28.
//

import XCTest
// 导入包含你的测试的 AppTests 模块
@testable import AppTests
// 为每个 XCTestCase 提供一组测试
XCTMain([
    testCase(AcronymTests.allTests),
    testCase(CategoryTests.allTests),
    testCase(UserTests.allTests)
])
